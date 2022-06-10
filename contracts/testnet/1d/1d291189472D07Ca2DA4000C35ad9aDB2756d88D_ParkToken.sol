//SPDX-License-Identifier: MIT
pragma solidity >=0.8.12 <0.9.0;



import '@openzeppelin/contracts/utils/Address.sol';
import '@openzeppelin/contracts/utils/math/SafeMath.sol';
import "./utils/pancake_swap/interfaces/IPancakeSwapV2Factory.sol";
import "./utils/pancake_swap/interfaces/IPancakeSwapV2Pair.sol";
import "./utils/pancake_swap/interfaces/IPancakeSwapV2Router02.sol";

import "./utils/private_vault/PrivateVault.sol";
import "./utils/vault/Vault.sol";
import "./utils/ido_vault/IDO_Vault.sol";
import "./utils/burn_vault/BurnVault.sol";
import "./utils/time_lock_DAO/TimeLockDAO.sol";
import "./interfaces/IParkToken.sol";



contract ParkToken is IParkToken {

    ///@dev Using SafeMath and Address library for uint256 and address
    using Address for address;
    using SafeMath for uint256;

    ///@dev Name and Symbol
    string public constant _NAME = "PARK";
    string public constant _SYMBOL = "PKT";

    ///@dev Decimals Supported
    uint8 private constant _DECIMALS = 18;

    ///@dev Supply
    uint256 private _tTotal = 4_000_000_000e18; //scientific decimal notation
    uint256 private constant _INITIAL_SUPPLY = 2_000_000_000e18; //scientific decimal notation

    ///@dev Mapping of address=>uint256 token Owned

    mapping(address => uint256) private _tOwned;

    ///@dev Allowances for the account
    mapping(address => mapping(address => uint256)) private _allowances;

    ///@dev Management for excluded accounts
    mapping(address => bool) private _isExcludedFromFee;
   

    ///@dev Fees management
    uint256 public communityLotteryFees = 30; //3%
    uint256 private _previouscommunityLotteryFees = communityLotteryFees;

    uint256 public LPAcquisitionFees = 20; //2%
    uint256 private _previousLPAcquisitionFees = LPAcquisitionFees;

    uint256 public commpanyFees = 20; //2%
    uint256 private _previouscommpanyFees = commpanyFees;

     uint256 public growthFundFees = 10; //1%
    uint256 private _previousgrowthFundFees = growthFundFees;

    uint256 private _tFeeTotal;

    ///@dev  Wallet address
    address public constant IDO_WALLET_ADDRESS =
        0x66723d60c2A28aCD61cf6af629105E179B96bf7D;
    address public constant PRIVATE_SALE_WALLET_ADDRESS =
        0xEfa30B8C6A7e81cBC9A91d8e87D8549F1a650eDE;
    address public constant LIQUIDITY_WALLET_ADDRESS =
        0x46E85B7e535c5d1b73ba979bcE628ded0e6D316d;
    address public constant REWARD_BUFFER_WALLET_ADDRESS =
        0x64749FA702F337d53a621f57f05ea4bA4Fe5f101;
    address public constant TEAM_WALLET_ADDRESS =
        0x7A8Da80ace009c2480B1940B04D56b6b3D4e0D32;
    address public constant DEVELOPEMENT_WALLET_ADDRESS =
        0xe50ab9F15c53b27D5C641709Fc9007B9ab595ae2;
    address public constant MARKETING_WALLET_ADDRESS =
        0x0dde7C315f990899c48c5623235b73e70B2dE04E;
    address public constant ADVISOR_WALLET_ADDRESS =
        0xA9Fdadb42d453cB99bA6911D4A18EDAA01dE1206;
    address public constant BURN_RESERVE_WALLET_ADDRESS =
        0x8D8CB87FbC6862A9acBCE8F7bA3990f0Dfaed034;
    address public constant AIRDROP_BOUNTY_WALLET_ADDRESS =
        0x23fCFb2fdeCdfdf1A8c2D41CFC63fd2f4B077b25;



    //TimeLockDAOContract
    address public  TIME_LOCK_DAO_ADDRESS;

    //VaultsContract   
    ///@dev  Wallet address
    address public  IDO_VAULT_ADDRESS;
    address public  PRIVATE_SALE_VAULT_ADDRESS;
    address public  LIQUIDITY_VAULT_ADDRESS;
    address public  REWARD_BUFFER_VAULT_ADDRESS;
    address public  TEAM_VAULT_ADDRESS ;
    address public  DEVELOPEMENT_VAULT_ADDRESS ;
    address public  MARKETING_VAULT_ADDRESS;
    address public  ADVISOR_VAULT_ADDRESS ;
    address public  BURN_RESERVE_VAULT_ADDRESS;
    address public  AIRDROP_BOUNTY_VAULT_ADDRESS ;

    mapping(address=>bool) isInternalWallet;
   


    address public  communityLottery_VAULT_ADDRESS;
    address public  LPAcquisition_ADDRESS ;
    address public  commpany_VAULT_ADDRESS;
    address public  growthFund_VAULT_ADDRESS ;



    ///@dev  Wallet percentage total=100%
    uint256 public constant IDO_PERCENTAGE = 150; //15%
    uint256 public constant PRIVATE_SALE_PERCENTAGE = 20; // 2%
    uint256 public constant LIQUIDITY_PERCENTAGE = 70; // 7%
    uint256 public constant REWARD_BUFFER_PERCENTAGE = 330; // 33%
    uint256 public constant TEAM_PERCENTAGE = 150; // 15%
    uint256 public constant DEVELOPEMENT_PERCENTAGE = 100; // 10%
    uint256 public constant MARKETING_PERCENTAGE = 100; // 10%
    uint256 public constant ADVISOR_PERCENTAGE = 20; // 2%
    uint256 public constant BURN_RESERVE_PERCENTAGE = 50; // 5%
    uint256 public constant AIR_DROP_BOUNTY_PERCENTAGE = 10; // 1%

    ///@dev Pancake-swap Router and pair address decleration
    IPancakeSwapV2Router02 public immutable pancakeswapV2Router;
    address public immutable pancakeswapV2Pair;

    ///@dev Swap and liquidity management
    bool public inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;

    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    ///@dev Max Trans. Amount & min token sell to add to liquidity
    uint256 public maxTxAmount = 2_000_000e18; //scientific decimal notation
    uint256 private _minTokensSellToAddToLiquidity = 2_000_000_000e18; //scientific decimal notation

    ///@dev Events in swap and liquify
    event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 bnbReceived,
        uint256 tokensIntoLiqudity
    );

    ///@dev Frequency and percentage of unlock
    uint256 public constant FREQUENCY_OF_UNLOCK = 365; // This value should be in day
    uint256 public constant PERSENTAGE_OF_UNLOCK = 1000; // 100%

    /// @dev locked token structure
    struct LockToken {
        uint256 amount;
        uint256 unlockAmount;
        uint256 persentageOfUnlock;
        uint256 frequencyOfUnlock;
        uint256 createdDate;
        uint256 previousUnlockDate;
    }

    /// @dev Holds number & validity of tokens locked for a given reason for a specified address
    mapping(address => LockToken) public locked;

    ///@dev All  locked accounts accounts
    address[] public totalAddress;

    ///@dev Events in swap and Locking
    event Locked(
        address indexed _of,
        uint256 _amount,
        uint256 persentageOfUnlock,
        uint256 _frequencyOfUnlock
    );

    ///@dev Is private sell Enabled
    bool public isEnablePrivateSell = true;

    ///@dev Is lottery launched
    bool public isLotteryLaunched = false;

    /// @author Developer Ram Krishan Pandey
    /// @notice This is a constructor in this we can assign rTotal to owner(msg.sender), using IUniswapV2Router02 for create pair of tokens.
    /// @dev Exclude owner and address(this) from fee, token burn with inityialSupply, exclude address(0), privatesellwalletaddress and burnReserveWalletAddress from reward, apply tokenomics with locking.
    constructor() {
       // _tOwned[msg.sender] = _tTotal-_INITIAL_SUPPLY;
        _tOwned[address(0)] = _INITIAL_SUPPLY;
        
        //Test net -0xD99D1c33F9fC3444f8101754aBC46c52416550D1
        //Main net- 0x10ED43C718714eb63d5aA57B78B54704E256024E 
            address pancakeSwapRouter=0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
        IPancakeSwapV2Router02 _pancakeswapV2Router = IPancakeSwapV2Router02(pancakeSwapRouter);
        pancakeswapV2Pair = IPancakeSwapV2Factory(
            _pancakeswapV2Router.factory()
        ).createPair(address(this), _pancakeswapV2Router.WETH());
        pancakeswapV2Router = _pancakeswapV2Router;

         initVaultContracts();
       
        //Burn 50% of total supply
        //_tokenBurn(msg.sender, _INITIAL_SUPPLY);

        _tokenomicsCalculation();

        emit Transfer(address(0), address(this), _tTotal-_INITIAL_SUPPLY);
    }

    function initVaultContracts() private {
         address[] memory mob=new address[](1);
         
         mob[0]=0xc31084130AEbf5774E2684008926aB230c20fc68;
       uint256 minHoldingAmount=2000000; 

       TimeLockDAO timeLock=new TimeLockDAO(mob,address(this),minHoldingAmount);

       TIME_LOCK_DAO_ADDRESS=address(timeLock);

      
      IDO_VAULT_ADDRESS=address(new IDOVault(address(this),TIME_LOCK_DAO_ADDRESS));
      PRIVATE_SALE_VAULT_ADDRESS=address(new PrivateVault(address(this),TIME_LOCK_DAO_ADDRESS, 1));
      LIQUIDITY_VAULT_ADDRESS=address(new Vault(address(this),TIME_LOCK_DAO_ADDRESS,"LIQUIDITY_VAULT"));
      REWARD_BUFFER_VAULT_ADDRESS=address(new Vault(address(this),TIME_LOCK_DAO_ADDRESS,"REWARD_BUFFER_VAULT"));
      TEAM_VAULT_ADDRESS =address(new Vault(address(this),TIME_LOCK_DAO_ADDRESS,"TEAM_VAULT"));
      DEVELOPEMENT_VAULT_ADDRESS =address(new Vault(address(this),TIME_LOCK_DAO_ADDRESS,"DEVELOPEMENT_VAULT"));
      MARKETING_VAULT_ADDRESS=address(new Vault(address(this),TIME_LOCK_DAO_ADDRESS,"MARKETING_VAULT"));
      ADVISOR_VAULT_ADDRESS =address(new Vault(address(this),TIME_LOCK_DAO_ADDRESS,"ADVISOR_VAULT"));
      BURN_RESERVE_VAULT_ADDRESS=address(new BurnVault(address(this),TIME_LOCK_DAO_ADDRESS));
      AIRDROP_BOUNTY_VAULT_ADDRESS =address(new Vault(address(this),TIME_LOCK_DAO_ADDRESS,"AIRDROP_BOUNTY_VAULT"));

      communityLottery_VAULT_ADDRESS=address(new Vault(address(this),TIME_LOCK_DAO_ADDRESS,"communityLottery_VAULT"));
      LPAcquisition_ADDRESS =address(new Vault(address(this),TIME_LOCK_DAO_ADDRESS,"LPAcquisition_VAULT"));
      commpany_VAULT_ADDRESS=address(new Vault(address(this),TIME_LOCK_DAO_ADDRESS,"commpany_VAULT"));
      growthFund_VAULT_ADDRESS =address(new Vault(address(this),TIME_LOCK_DAO_ADDRESS,"growthFund_VAULT"));

         isInternalWallet[0x66723d60c2A28aCD61cf6af629105E179B96bf7D]=true;
         isInternalWallet[0xEfa30B8C6A7e81cBC9A91d8e87D8549F1a650eDE]=true;
         isInternalWallet[0x46E85B7e535c5d1b73ba979bcE628ded0e6D316d]=true;
         isInternalWallet[0x64749FA702F337d53a621f57f05ea4bA4Fe5f101]=true;
         isInternalWallet[0x7A8Da80ace009c2480B1940B04D56b6b3D4e0D32]=true;
         isInternalWallet[0xe50ab9F15c53b27D5C641709Fc9007B9ab595ae2]=true;
         isInternalWallet[0x0dde7C315f990899c48c5623235b73e70B2dE04E]=true;
         isInternalWallet[0xA9Fdadb42d453cB99bA6911D4A18EDAA01dE1206]=true;
         isInternalWallet[0x8D8CB87FbC6862A9acBCE8F7bA3990f0Dfaed034]=true;
         isInternalWallet[0x23fCFb2fdeCdfdf1A8c2D41CFC63fd2f4B077b25]=true;

          _isExcludedFromFee[address(this)] = true;
    }

    /// @notice This function required recipient address, amount and use for locking token for a time duration like :- 1/3 months.
    /// @dev stored in structure with (amount,unlockAmount,persentageOfUnlock,frequencyOfUnlock,createdDate, previousUnlockDate). UnlockAmount calculate (amount * persentageOfUnlock / 10**3).
    /// @param @address recipient, uint256 _amount
    /// @return true
    function lock(address recipient, uint256 _amount) public returns (bool) {
        require(_amount != 0, "Amount can not be 0");
        if (locked[recipient].amount > 0) {
            uint256 unlockAmount = 0;
            locked[recipient].amount += _amount;
            locked[recipient].unlockAmount += unlockAmount;
            locked[recipient].previousUnlockDate = block.timestamp;
        } else {
            uint256 unlockAmount = 0;
            locked[recipient] = LockToken(
                _amount,
                unlockAmount,
                PERSENTAGE_OF_UNLOCK,
                FREQUENCY_OF_UNLOCK,
                block.timestamp,
                block.timestamp
            );
            totalAddress.push(recipient);
        }

        emit Locked(
            msg.sender,
            _amount,
            PERSENTAGE_OF_UNLOCK,
            FREQUENCY_OF_UNLOCK
        );
        return true;
    }

    /// @notice This function required recipient address and use for calculate lock token balance for a particular recipient address
    /// @dev update unlockAmount and previousUnlockDate in locked struct.
    /// @param @address recipient
    /// @return lockamount
    function calculateLockBalance(address recipient)
        public
        view
        returns (uint256)
    {
        uint256 unlockAmount = 0;
        uint256 lockAmount = 0;

        if (locked[recipient].amount > 0) {
            uint256 unlockDate = 0;
            unlockDate =
                locked[recipient].previousUnlockDate +
                (60 * 60 * 24 * locked[recipient].frequencyOfUnlock);
            if (block.timestamp >= unlockDate) {
                uint256 count = (block.timestamp -
                    locked[recipient].previousUnlockDate) /
                    (60 * 60 * 24 * locked[recipient].frequencyOfUnlock);
                unlockAmount =
                    ((locked[recipient].amount *
                        locked[recipient].persentageOfUnlock) / 10**3) *
                    count;
                unlockDate = block.timestamp;
            }
            unlockAmount = locked[recipient].unlockAmount + unlockAmount;
        }
        if (locked[recipient].amount > unlockAmount) {
            lockAmount = locked[recipient].amount - unlockAmount;
        }
        return lockAmount;
    }

    /// @notice This function required recipient address and use for unlocking token for a particular recipient address
    /// @dev update unlockAmount and previousUnlockDate in locked struct.
    /// @param @address recipient
    /// @return true
    function unLock(address recipient) public returns (bool) {
        if (locked[recipient].amount > 0) {
            bool isModify = false;
            uint256 unlockDate = 0;
            uint256 unlockAmount = 0;
            unlockDate =
                locked[recipient].previousUnlockDate +
                (60 * 60 * 24 * locked[recipient].frequencyOfUnlock);
            if (block.timestamp >= unlockDate) {
                uint256 count = (block.timestamp -
                    locked[recipient].previousUnlockDate) /
                    (60 * 60 * 24 * locked[recipient].frequencyOfUnlock);
                unlockAmount =
                    ((locked[recipient].amount *
                        locked[recipient].persentageOfUnlock) / 10**3) *
                    count;
                unlockDate = block.timestamp;
                isModify = true;
            }

            if (isModify) {
                if (BURN_RESERVE_WALLET_ADDRESS == recipient) {
                    if (
                        locked[recipient].unlockAmount + unlockAmount >
                        locked[recipient].amount
                    ) {
                        _tokenBurn(
                            BURN_RESERVE_WALLET_ADDRESS,
                            locked[recipient].amount -
                                locked[recipient].unlockAmount
                        );
                        delete locked[recipient]; // delete record from struct
                        _removeLockAddress(recipient);
                    } else {
                        _tokenBurn(BURN_RESERVE_WALLET_ADDRESS, unlockAmount);
                        locked[recipient].unlockAmount += unlockAmount;
                        locked[recipient].previousUnlockDate = unlockDate;
                    }
                } else if (
                    locked[recipient].unlockAmount + unlockAmount >=
                    locked[recipient].amount
                ) {
                    locked[recipient].unlockAmount +=
                        locked[recipient].amount -
                        locked[recipient].unlockAmount;
                    locked[recipient].previousUnlockDate = unlockDate;
                    delete locked[recipient]; // delete record from struct
                    _removeLockAddress(recipient);
                } else {
                    //unLockToken[recipient] += unlockAmount;
                    locked[recipient].unlockAmount += unlockAmount;
                    locked[recipient].previousUnlockDate = unlockDate;
                }
            }
        }
        return true;
    }

    /// @notice This function used for get unlockAmount of a recipient.
    /// @dev Get recipient balance and subtract with amount or unlockAmount
    /// @param @address recipient
    /// @return unlockbalance
    function unlockBalanceof(address recipient) public view returns (uint256) {
        uint256 _lockBalance = calculateLockBalance(recipient);
        uint256 _unlockBalance = balanceOf(recipient) - _lockBalance;
        return _unlockBalance;
    }

    /// @notice This private function required recipient address and use for remove particular address from totalAddress array.
    /// @dev apply loop on totalAddress get perticular address match with recipient and delete from array
    /// @param @address recipient
    /// @return true
    function _removeLockAddress(address recipient) private returns (bool) {
        for (uint256 i = 0; i < totalAddress.length; i++) {
            if (totalAddress[i] == recipient) {
                delete totalAddress[i];
            }
        }
        return true;
    }

    /// @notice This function required initialSupply and use for calculation tokenomics with locking and unlocking tokens given tokenomics percentages.
    /// @dev transfer tokens to different tokenomics wallets
    /// @param @uint256 initialSupply
    /// @return true
    function _tokenomicsCalculation()
        private 
        returns (bool)
    {
        //For IDO Wallet
        _isExcludedFromFee[IDO_WALLET_ADDRESS] = true;
        uint256 idoAmount = (_INITIAL_SUPPLY * IDO_PERCENTAGE) / 10**3;
        //transfer(IDO_WALLET_ADDRESS, idoAmount);
        _tOwned[IDO_WALLET_ADDRESS] = idoAmount;
       // 100% unlocked At TGE
        emit Transfer(IDO_WALLET_ADDRESS, address(this), idoAmount);

        //For Private sale Wallet
        _isExcludedFromFee[PRIVATE_SALE_WALLET_ADDRESS] = true;
        uint256 privateSaleAmount = (_INITIAL_SUPPLY * PRIVATE_SALE_PERCENTAGE) /
            10**3;
        //transfer(PRIVATE_SALE_WALLET_ADDRESS, privateSaleAmount);
         _tOwned[PRIVATE_SALE_WALLET_ADDRESS] = privateSaleAmount;
        //Cliff for 12 months and then fully unlocked for buyers through private sale
         emit Transfer(PRIVATE_SALE_WALLET_ADDRESS, address(this), privateSaleAmount);

        //For Liqidity Wallet
        _isExcludedFromFee[LIQUIDITY_WALLET_ADDRESS] = true;
        uint256 liquidityAmount = (_INITIAL_SUPPLY * LIQUIDITY_PERCENTAGE) /
            10**3;
        //transfer(LIQUIDITY_WALLET_ADDRESS, liquidityAmount);
        _tOwned[LIQUIDITY_WALLET_ADDRESS] = liquidityAmount;
         emit Transfer(LIQUIDITY_WALLET_ADDRESS, address(this), liquidityAmount);
        //100% unlocked At TGE

        //For Reward Buffer Wallet
        _isExcludedFromFee[REWARD_BUFFER_WALLET_ADDRESS] = true;
        uint256 rewardBufferAmount = (_INITIAL_SUPPLY *
            REWARD_BUFFER_PERCENTAGE) / 10**3;
        //transfer(REWARD_BUFFER_WALLET_ADDRESS, rewardBufferAmount);
       _tOwned[REWARD_BUFFER_WALLET_ADDRESS] = rewardBufferAmount;
        emit Transfer(REWARD_BUFFER_WALLET_ADDRESS, address(this),rewardBufferAmount);

        //For Team Wallet
        _isExcludedFromFee[TEAM_WALLET_ADDRESS] = true;
        uint256 teamAmount = (_INITIAL_SUPPLY * TEAM_PERCENTAGE) / 10**3;
        //transfer(TEAM_WALLET_ADDRESS, teamAmount);
       _tOwned[TEAM_WALLET_ADDRESS] = teamAmount;
 emit Transfer(TEAM_WALLET_ADDRESS, address(this), teamAmount);

        //For Developement Wallet
        _isExcludedFromFee[DEVELOPEMENT_WALLET_ADDRESS] = true;
        uint256 developmentAmount = (_INITIAL_SUPPLY * DEVELOPEMENT_PERCENTAGE) /
            10**3;
        //transfer(DEVELOPEMENT_WALLET_ADDRESS, developmentAmount);
        _tOwned[DEVELOPEMENT_WALLET_ADDRESS] = developmentAmount;
         emit Transfer(DEVELOPEMENT_WALLET_ADDRESS, address(this), developmentAmount);

        //For Marketing Wallet
        _isExcludedFromFee[MARKETING_WALLET_ADDRESS] = true;
        uint256 marketingFeesAmount = (_INITIAL_SUPPLY * MARKETING_PERCENTAGE) /
            10**3;
        //transfer(MARKETING_WALLET_ADDRESS, marketingFeesAmount);
        _tOwned[MARKETING_WALLET_ADDRESS] = marketingFeesAmount;
  emit Transfer(MARKETING_WALLET_ADDRESS, address(this),marketingFeesAmount);

        //For Advisior Wallet
        _isExcludedFromFee[ADVISOR_WALLET_ADDRESS] = true;
        uint256 advisorFeesAmount = (_INITIAL_SUPPLY * ADVISOR_PERCENTAGE) /
            10**3;
        //transfer(ADVISOR_WALLET_ADDRESS, advisorFeesAmount);
    _tOwned[ADVISOR_WALLET_ADDRESS] = advisorFeesAmount;
     emit Transfer(ADVISOR_WALLET_ADDRESS, address(this),advisorFeesAmount);

        //For Burn Reserve Wallet
        _isExcludedFromFee[BURN_RESERVE_WALLET_ADDRESS] = true;
        uint256 burnReserveFeesAmount = (_INITIAL_SUPPLY *
            BURN_RESERVE_PERCENTAGE) / 10**3;
        //transfer(BURN_RESERVE_WALLET_ADDRESS, burnReserveFeesAmount);
        _tOwned[BURN_RESERVE_WALLET_ADDRESS] = burnReserveFeesAmount;
         emit Transfer(BURN_RESERVE_WALLET_ADDRESS, address(this), burnReserveFeesAmount);
        //33% Burned at Lottery launch, then linearly burned for 6 months until fully burned

        //For AirdropBounty Wallet
        _isExcludedFromFee[AIRDROP_BOUNTY_WALLET_ADDRESS] = true;
      
        uint256 airdropBountyAmount = (_INITIAL_SUPPLY *
            AIR_DROP_BOUNTY_PERCENTAGE) / 10**3;
        //transfer(AIRDROP_BOUNTY_WALLET_ADDRESS, airdropBountyAmount);
        _tOwned[AIRDROP_BOUNTY_WALLET_ADDRESS] = airdropBountyAmount;
         emit Transfer(AIRDROP_BOUNTY_WALLET_ADDRESS, address(this), airdropBountyAmount);
      //  100% unlocked At TGE
        return true;
    }

    function lotterylaunchEvent() external  {
        require(msg.sender==TIME_LOCK_DAO_ADDRESS, "caller is not timeLockDAO");
        isLotteryLaunched = true;
        uint256 burnReserveFeesAmount = (_INITIAL_SUPPLY *
            BURN_RESERVE_PERCENTAGE) / 10**3;
        //33% Burned at Lottery launch, then linearly burned for 6 months until fully burned(Simplified 5% per 9 days, because of linear nature)
        uint256 burnReservekUnlockAmount = (burnReserveFeesAmount * 330) /
            10**3; //33 %
        //Burn 33%
        _tokenBurn(BURN_RESERVE_WALLET_ADDRESS, burnReservekUnlockAmount);
        
    }

    /// @notice This function required sender address, amount and use for burn tokens with address(0).
    /// @dev calling private function _tokenTransfer
    /// @param @address _sender, uint256 amount
    /// @return true
    function _tokenBurn(address sender, uint256 amount) private returns (bool) {
       
        if (sender==BURN_RESERVE_VAULT_ADDRESS)
            require(
                isLotteryLaunched,
                "Can not Burn Tokens Lottery yet not launched"
            );
        bool takeFee = false;
      
        _tokenTransfer(sender, address(0), amount, takeFee);
        
        return true;
    }

    /// @notice This setter function reset isEnablePrivateSell .
    /// @dev setter function enable private sell
    /// @param  _isEnablePrivateSell bool
    function SetisEnablePrivateSell(bool _isEnablePrivateSell)
        external
    
    {
        require(msg.sender==TIME_LOCK_DAO_ADDRESS,"Only Time Lock Can Call This function");
        isEnablePrivateSell = _isEnablePrivateSell;
    }

    function name() external pure returns (string memory) {
        return _NAME;
    }

    function symbol() external pure returns (string memory) {
        return _SYMBOL;
    }

    function decimals() external pure returns (uint8) {
        return _DECIMALS;
    }

    function totalSupply() external view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
     
        return _tOwned[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        external
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        external
        override
        returns (bool)
    {
        _approve(msg.sender, spender, amount);
        return true;
    }
     function getPrivateSaleStatus() public override view returns(bool){
      return isEnablePrivateSell;
     }
     function getLotteryLaunchStatus() public override view returns(bool){
       return isLotteryLaunched;
     }
     function isInternalWallets(address address_) public override view returns(bool){
        return isInternalWallet[address_];
     }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        require(
            _allowances[sender][msg.sender] >= amount,
            "Spender doesnot have enough allowances"
        );
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            msg.sender,
            _allowances[sender][msg.sender].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    /// @notice This function is required spender address and amount to increase allowance amount in spender
    /// @dev calling private function _approve
    /// @param @address spender, uint256 addedValue
    /// @return true
    function increaseAllowance(address spender, uint256 addedValue)
        external
        virtual
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].add(addedValue)
        );
        return true;
    }

    /// @notice This function is required spender address and amount to decrease allowance amount in spender.
    /// @dev calling private function _approve
    /// @param @address spender, uint256 subtractedValue
    /// @return true
    function decreaseAllowance(address spender, uint256 subtractedValue)
        external
        virtual
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }

   

   



    function setMaxTxPercent(uint256 maxTxPercent) external  {
        require(msg.sender==TIME_LOCK_DAO_ADDRESS,"Only Time Lock Can Call This function");
        maxTxAmount = _tTotal.mul(maxTxPercent).div(10**3);
    }

    function setSwapAndLiquifyEnabled(bool _enabled) external  {
        require(msg.sender==TIME_LOCK_DAO_ADDRESS,"Only Time Lock Can Call This function");
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    receive() external payable {}

   function withdraw(uint _amount) external {
        require(msg.sender == TIME_LOCK_DAO_ADDRESS, "caller is not timeLockDAO");
        payable(msg.sender).transfer(_amount);
   }


    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {

         require(from != address(0), "ERC20: transfer from the zero address");
        if(from!=BURN_RESERVE_VAULT_ADDRESS){
          require(to != address(0), "ERC20: transfer to the zero address");   
        }
        
      
        
        require(amount > 0, "Transfer amount must be greater than zero");

        if (from != TIME_LOCK_DAO_ADDRESS )
            require(
                amount <= maxTxAmount,
                "Transfer amount exceeds the maxTxAmount."
            );

        uint256 contractTokenBalance = balanceOf(address(this));

        if (contractTokenBalance >= maxTxAmount) {
            contractTokenBalance = maxTxAmount;
        }
        bool overMinTokenBalance = contractTokenBalance >=
            _minTokensSellToAddToLiquidity;
        if (
            overMinTokenBalance &&
            !inSwapAndLiquify &&
            from != pancakeswapV2Pair &&
            swapAndLiquifyEnabled
        ) {
            contractTokenBalance = _minTokensSellToAddToLiquidity;
            _swapAndLiquify(contractTokenBalance);
        }
        bool takeFee = true;
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            takeFee = false;
        }
        _tokenTransfer(from, to, amount, takeFee);
    }

    function _swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);
        //uint256 initialBalance = address(this).balance;
        _swapTokensForEth(half);
        // uint256 newBalance = address(this).balance.sub(initialBalance);
        uint256 newBalance = address(this).balance;
        _addLiquidity(otherHalf, newBalance);
        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function _swapTokensForEth(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = pancakeswapV2Router.WETH();
        _approve(address(this), address(pancakeswapV2Router), tokenAmount);
        pancakeswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function _addLiquidity(uint256 tokenAmount, uint256 bnbAmount) private {
        _approve(address(this), address(pancakeswapV2Router), tokenAmount);
        pancakeswapV2Router.addLiquidityETH{value: bnbAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            TIME_LOCK_DAO_ADDRESS,
            block.timestamp
        );
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount,
        bool takeFee
    ) private {
        uint256 _unlockBalance = unlockBalanceof(sender);
        require(
            _unlockBalance >= amount,
            "ERC20: Transfer amount exceed from unlock amount."
        );

      

       
       _transferStandard(sender, recipient, amount);
    
        unLock(sender);
       
    }

    function _transferStandard(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
       

         

        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tAmount);

        if(!isExcludedFromFee(sender)){

            //test net bnb -0xD99D1c33F9fC3444f8101754aBC46c52416550D1
            address bnb= 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
            address[] memory path;
            path[0]=address(this);
            path[1]=bnb;
            uint256[] memory amount=  pancakeswapV2Router.getAmountsOut(1,path );
            require(msg.value>=amount[0].mul(8).div(100).mul(tAmount),"Minimum Fees Required in value");

            payable(communityLottery_VAULT_ADDRESS).transfer((msg.value).mul(communityLotteryFees).div(1000));
            payable(LPAcquisition_ADDRESS).transfer((msg.value).mul(LPAcquisitionFees).div(1000));
            payable(commpany_VAULT_ADDRESS).transfer((msg.value).mul(commpanyFees).div(1000));
            payable(growthFund_VAULT_ADDRESS).transfer((msg.value).mul(growthFundFees).div(1000));

        }   

        if (isEnablePrivateSell && PRIVATE_SALE_WALLET_ADDRESS == sender) {
            lock(recipient, tAmount);
        }
        emit Transfer(sender, recipient, tAmount);
    }

 
}

//SPDX-License-Identifier: MIT
pragma solidity >=0.8.12 <0.9.0;

interface IVault { 

   
   function getVaultName() external view returns(string memory);

   function transfer(address to_,uint256 amount_) external;

   function withdraw(uint _amount) external;

}

//SPDX-License-Identifier: MIT
pragma solidity >=0.8.12 <0.9.0;

//Import required contracts
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/utils/Address.sol';
import '@openzeppelin/contracts/utils/Context.sol';
import '../../interfaces/IParkToken.sol';
import './interface/IVault.sol';



contract Vault is Context,IVault{ 

   //Using Address for address
   using Address for address;

   address private _parkToken;
   address private _timeLockDAO;

   string private  _vaultName;

   bool private _isIDOVault;

   mapping(address=>bool) isWallets;


   constructor(address parkToken_,address timeLockDAO_,string memory vaultName_ ){

       //Initilizes the _vaultOwner and _vaultName
        _timeLockDAO=timeLockDAO_;
        _parkToken=parkToken_;
        _vaultName=vaultName_;

       
   }
   
   function getVaultName() public override view returns(string memory){
       return _vaultName;
   }

   function transfer(address to_,uint256 amount_)public override{

       //requires private sale is not active
       IParkToken parkTokens =IParkToken(_parkToken);
       require(parkTokens.getPrivateSaleStatus()==false,"Can`t transfer private sale is still active");

       //requires sender is timeLockDAO contract 
       if(_isIDOVault){
        require(_msgSender()==_timeLockDAO||isWallets[_msgSender()],"Not Enough Authority");
       }
       else{
        require(_msgSender()==_timeLockDAO, "caller is not timeLockDAO");   
       }
   
       IERC20 parkToken=IERC20(_parkToken);
       parkToken.transfer(to_, amount_);
   }

    //Function to recive BNB 
    receive() external payable {}

   function withdraw(uint _amount) external override{
        require(msg.sender == _timeLockDAO, "caller is not timeLockDAO");
        payable(msg.sender).transfer(_amount);
   }



}

//SPDX-License-Identifier: MIT
pragma solidity >=0.8.12 <0.9.0;


/// @title Time Lock + DAO interface
/// @author Ram Krishan Pandey


interface ITimeLockDAO {


    //Errors that might occur during execution
    error NotMOBError();  //Not a member of board Error
    error NotMOBorHolderError(); //Neither a member of board nor a holder having minimum balance Error
    error AlreadyQueuedError(bytes32 txId); //Already Queued Error
    error TimestampNotInRangeError(uint blockTimestamp, uint timestamp); //Timestamp not in range Error
    error NotQueuedError(bytes32 txId); //Not Queued Error
    error TimestampNotPassedError(uint blockTimestmap, uint timestamp); //Timestamp not passed Error
    error TimestampExpiredError(uint blockTimestamp, uint expiresAt); //Timestamp expired Error
    error TxFailedError(); //Tx failed Error
    error AlreadyVotedError();//Already voted Error
    error NotMinVotesError(); //Not minimum votes Error 


   //Events
    event Queue(
        bytes32 indexed txId,
        address indexed target,
        uint value,
        string func,
        bytes data,
        uint timestamp
    ); 

    event Execute(
        bytes32 indexed txId,
        address indexed target,
        uint value,
        string func,
        bytes data,
        uint timestamp
    );
    event Cancel(bytes32 indexed txId);


    //Function To Create a Transaction ID
    function getTxId(
        address _target,
        uint _value,
        string calldata _func,
        bytes calldata _data,
        uint _timestamp
    ) external  returns (bytes32);

    /**
     * @param _target Address of contract or account to call
     * @param _value Amount of BNB to send
     * @param _func Function signature, for example "foo(address,uint256)"
     * @param _data ABI encoded data send.
     * @param _timestamp Timestamp after which the transaction can be executed.
     */
    function queue(
        address _target,
        uint _value,
        string calldata _func,
        bytes calldata _data,
        uint _timestamp
    ) external  returns (bytes32 txId);

    function execute(
        address _target,
        uint _value,
        string calldata _func,
        bytes calldata _data,
        uint _timestamp
    ) external payable  returns (bytes memory);

    function cancel(bytes32 _txId) external;

    function vote(bytes32 txID_) external;
}

//SPDX-License-Identifier: MIT
pragma solidity >=0.8.12 <0.9.0;

import '@openzeppelin/contracts/utils/Context.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/utils/math/SafeMath.sol';
import './interface/ITimeLockDAO.sol';

/// @title Time Lock + DAO contract
/// @author Ram Krishan Pandey
/// @notice Time Lock + DAO contract creates a perposal on the smart contract 
/// @dev Anyone holding ParkTokens more than a minimum balance or membes of boards can 
///      create a perposal and if the voting goes more than 50% for that perticular perposal 
///      then member of boards can either execute or can cancel the function within a certain peroid of time

contract TimeLockDAO is ITimeLockDAO{

    //Using SafeMath for uint256
    using SafeMath for uint256;


    //Delays
    uint public constant MIN_DELAY = 10; // seconds
    uint public constant MAX_DELAY = 1000; // seconds
    uint public constant GRACE_PERIOD = 1000; // seconds

    //Initial Supply of park Token
    uint256 private constant _INITIAL_SUPPLY = 2_000_000_000e18; //scientific decimal notation

    //Park Token Address
    address private _parkToken;

    //Minimum Holding balance required to create a perposal
    uint256 private _minHoldBlanace;

    //Struct of QueueDetails
    struct QueueDetails{
        bool isActive;
        uint256 mobVotes;
        uint256 holdersVotes;
    }
    


    //Mapping for Queued functions
    mapping(bytes32 => QueueDetails) public queued;

    //Mapping for voted address for a perticular queued function
    mapping(bytes32=>mapping(address=>bool)) isVoted;
    
    //Mapping for member of boards
    mapping(address=>bool) isMOB;

    //Member of boards 
    address[] private _MOBs;

    constructor(address[] memory MOBs_,address parkToken_,uint256 minHoldBalance_) {
        
        //Initilize Member of Boards
        for(uint i=0;i<MOBs_.length;i++){
           isMOB[MOBs_[i]]=true;
        }

        //Initilize park Token address
        _parkToken=parkToken_;

        //Initilize minium holding balance to create a perposal
        _minHoldBlanace=minHoldBalance_;
         
        //Initilizes Member of boards
        _MOBs =MOBs_;

    }

   //Modifier for only member of boards
    modifier onlyMOB() {
        if (!isMOB[msg.sender]) {
            revert NotMOBError();
        }
        _;
    }

    //Modifier for either member of boards or Holder with some minimum balance of park token 
    modifier onlyMOBorHolder() {

       
        if (!isMOB[msg.sender]) {

           IERC20 parkToken=IERC20(_parkToken);
           uint256 balance= parkToken.balanceOf(msg.sender);

            if(!(balance>=_minHoldBlanace)){
               revert NotMOBorHolderError();
            } 
        }
        _;
    }
    
    //Function to recive BNB 
    receive() external payable {}

    function withdraw(uint _amount) external {
        require(isMOB[msg.sender], "caller is not timeLockDAO");
        payable(msg.sender).transfer(_amount);
   }

    //Function To Create a Transaction ID
    function getTxId(
        address _target,
        uint _value,
        string calldata _func,
        bytes calldata _data,
        uint _timestamp
    ) public pure override  returns (bytes32) {
        return keccak256(abi.encode(_target, _value, _func, _data, _timestamp));
    }

    /**
     * @param _target Address of contract or account to call
     * @param _value Amount of BNB to send
     * @param _func Function signature, for example "foo(address,uint256)"
     * @param _data ABI encoded data send.
     * @param _timestamp Timestamp after which the transaction can be executed.
     */
    function queue(
        address _target,
        uint _value,
        string calldata _func,
        bytes calldata _data,
        uint _timestamp
    ) external override onlyMOBorHolder returns (bytes32 txId) {
        txId = getTxId(_target, _value, _func, _data, _timestamp);
        if (queued[txId].isActive) {
            revert AlreadyQueuedError(txId);
        }
        
        // ---|------------|---------------|-------
        //  block    block + min     block + max
        if (
            _timestamp < block.timestamp + MIN_DELAY ||
            _timestamp > block.timestamp + MAX_DELAY
        ) {
            revert TimestampNotInRangeError(block.timestamp, _timestamp);
        }

        queued[txId].isActive = true;

        emit Queue(txId, _target, _value, _func, _data, _timestamp);
    }

    function execute(
        address _target,
        uint _value,
        string calldata _func,
        bytes calldata _data,
        uint _timestamp
    ) external override payable onlyMOB returns (bytes memory) {
        bytes32 txId = getTxId(_target, _value, _func, _data, _timestamp);
        if (!queued[txId].isActive) {
            revert NotQueuedError(txId);
        }
        // ----|-------------------|-------
        //  timestamp    timestamp + grace period
        if (block.timestamp < _timestamp) {
            revert TimestampNotPassedError(block.timestamp, _timestamp);
        }
        if (block.timestamp > _timestamp + GRACE_PERIOD) {
            revert TimestampExpiredError(block.timestamp, _timestamp + GRACE_PERIOD);
        }
        
        uint256 votepercentage= (queued[txId].mobVotes).div((_MOBs.length).mul(100).div(90)).mul(100)+ queued[txId].holdersVotes.div(_INITIAL_SUPPLY.mul(100).div(10)).mul(100);

       if (votepercentage<=50) {
            revert NotMinVotesError();
        }

        queued[txId].isActive = false;

        // prepare data
        bytes memory data;
        if (bytes(_func).length > 0) {
            // data = func selector + _data
            data = abi.encodePacked(bytes4(keccak256(bytes(_func))), _data);
        } else {
            // call fallback with data
            data = _data;
        }

        // call target
        (bool ok, bytes memory res) = _target.call{value: _value}(data);
        if (!ok) {
            revert TxFailedError();
        }

        emit Execute(txId, _target, _value, _func, _data, _timestamp);

        return res;
    }

    function cancel(bytes32 _txId) external override onlyMOB{
        if (!queued[_txId].isActive) {
            revert NotQueuedError(_txId);
        }

        queued[_txId].isActive = false;

        emit Cancel(_txId);
    }

    function vote(bytes32 txID_) external override {

        if (!queued[txID_].isActive) {
            revert NotQueuedError(txID_);
        }

       if(isMOB[msg.sender]){
          if(isVoted[txID_][msg.sender]){
                revert AlreadyVotedError();
          }
          else{
              isVoted[txID_][msg.sender]=true;
              queued[txID_].mobVotes +=1;
          }
       }
       else{
              if(isVoted[txID_][msg.sender]){
                revert AlreadyVotedError();
          }
          else{
              IERC20 parkToken =IERC20(_parkToken);
              uint256 voteWeight =parkToken.balanceOf(msg.sender);
              queued[txID_].holdersVotes +=voteWeight;
          }

       }
    }
}

//SPDX-License-Identifier: MIT
pragma solidity >=0.8.12 <0.9.0;




interface IPrivateVault{ 

   event PriceChanged(uint256 _oldAmount,uint256 _newAmount);

   
   function getVaultName() external pure  returns(string memory);

   function transfer(address to_,uint256 amount_)external ;
   
   function buyParkToken() external payable;

   function changePrice(uint256 newPrice_) external ;

   function withdraw(uint _amount) external ;
}

//SPDX-License-Identifier: MIT
pragma solidity >=0.8.12 <0.9.0;

//Import required contracts
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/utils/Address.sol';
import '@openzeppelin/contracts/utils/math/SafeMath.sol';
import '@openzeppelin/contracts/utils/Context.sol';
import '../../interfaces/IParkToken.sol';
import './interface/IPrivateVault.sol';



contract PrivateVault is Context, IPrivateVault{ 


   using Address for address;

   using SafeMath for uint256;

   address private _parkToken;
   address private _timeLockDAO;

   string private  constant _VAULT_NAME='PRIVATE SALE VAULT';

   uint256 private _price; //in wei


   constructor(address parkToken_,address timeLockDAO_ ,uint256 price_){

   
        _timeLockDAO=timeLockDAO_;
        _parkToken=parkToken_;
        _price=price_;
   }
   
   function getVaultName() public pure override returns(string memory){
       return _VAULT_NAME;
   }

   function transfer(address to_,uint256 amount_)public override{

    
       require(_msgSender()==_timeLockDAO,"You don`t have authority");

       //requires private sale is not active
       IParkToken parkToken =IParkToken(_parkToken);
       require(parkToken.getPrivateSaleStatus()==false,"Can`t transfer private sale is still active");

       IERC20 parkTokens=IERC20(_parkToken);
       parkTokens.transfer(to_, amount_);
   }

   receive() payable external{
       
   }
   
   function buyParkToken() public override payable{

       //have Enough amount to buy tokens
       require(msg.value>_price,"Min balance doesnot meet");

       //value should be multiple of price
       require(msg.value%_price==0,"value should be in multiple of price");

       transfer(_msgSender(), msg.value.div(_price));
   }

   function changePrice(uint256 newPrice_) public override{
       require(_msgSender()==_timeLockDAO, "caller is not timeLockDAO");
       emit PriceChanged(_price, newPrice_);
       _price=newPrice_;
   }

   function withdraw(uint _amount) external override{
        require(msg.sender == _timeLockDAO, "caller is not timeLockDAO");
        payable(msg.sender).transfer(_amount);
   }

}

//SPDX-License-Identifier:MIT
pragma solidity >=0.6.2;

import './IPancakeSwapV2Router01.sol';

interface IPancakeSwapV2Router02 is IPancakeSwapV2Router01 {
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

//SPDX-License-Identifier:MIT
pragma solidity >=0.6.2;

interface IPancakeSwapV2Router01 {
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

//SPDX-License-Identifier:MIT
pragma solidity >=0.5.0;

interface IPancakeSwapV2Pair {
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

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

//SPDX-License-Identifier:MIT
pragma solidity >=0.5.0;

interface IPancakeSwapV2Factory {
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

//SPDX-License-Identifier: MIT
pragma solidity >=0.8.12 <0.9.0;

interface IIDOVault { 

   
   function getVaultName() external view returns(string memory);

   function transfer(address to_,uint256 amount_) external;

   function withdraw(uint _amount) external;
}

//SPDX-License-Identifier: MIT
pragma solidity >=0.8.12 <0.9.0;


import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/utils/Address.sol';
import '@openzeppelin/contracts/utils/Context.sol';
import '../../interfaces/IParkToken.sol';
import './interface/IIDOVault.sol';


contract IDOVault is Context,IIDOVault{ 


   using Address for address;

   address private _parkToken;
   address private _timeLockDAO;

   string private constant  _VAULT_NAME="IDO VAULT";


   constructor(address parkToken_,address timeLockDAO_){


        _timeLockDAO=timeLockDAO_;
        _parkToken=parkToken_;
   }
   
   function getVaultName() public override pure returns(string memory){
       return _VAULT_NAME;
   }


   function transfer(address to_,uint256 amount_)public override{
       
         IParkToken parkToken =IParkToken(_parkToken);

        
         require(_msgSender()==_timeLockDAO||parkToken.isInternalWallets(_msgSender()),"You are Not Authorized");
         parkToken.transfer(to_, amount_);
   }
     receive() external payable {

   }

   function withdraw(uint _amount) external override{
        require(msg.sender == _timeLockDAO, "You does not have enough authority");
        payable(msg.sender).transfer(_amount);
   }



}

//SPDX-License-Identifier: MIT
pragma solidity >=0.8.12 <0.9.0;

interface IBurnVault { 

   
   function getVaultName() external view returns(string memory);

   function burnTokens(uint256 amount_) external;

   function withdraw(uint _amount) external;

}

//SPDX-License-Identifier: MIT
pragma solidity >=0.8.12 <0.9.0;

//Import required contracts
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/utils/Address.sol';
import '@openzeppelin/contracts/utils/Context.sol';
import '../../interfaces/IParkToken.sol';
import './interface/IBurnVault.sol';


/// @title Vault Contract
/// @author Ram Krishan Pandey
/// @dev Vaults are the smart contract which holds some park token but transfer of these tokens are governed by owner of this contract which may be followed by dao+time-lock

contract BurnVault is Context,IBurnVault{ 

   //Using Address for address
   using Address for address;

   address private _parkToken;
   address private _timeLockDAO;

   string private constant  _VAULT_NAME="BURN RESERVE VAULT";

   constructor(address parkToken_,address timeLockDAO_){

       //Initilizes the _vaultOwner and _vaultName
        _timeLockDAO=timeLockDAO_;
        _parkToken=parkToken_;
       
   }


   function getVaultName() public pure override  returns(string memory){
       return _VAULT_NAME;
   }

   function burnTokens(uint256 amount_)public override{

       //requires private sale is not active
        IParkToken parkToken =IParkToken(_parkToken);
        require(parkToken.getLotteryLaunchStatus()==true,"Can`t transfer while lottery is not launched");
        require(_msgSender()==_timeLockDAO,"You does not have enough authority");   

        parkToken.transfer(address(0), amount_);
   }


   receive() external payable {

   }

   function withdraw(uint _amount) external override{
        require(msg.sender == _timeLockDAO, "You does not have enough authority");
        payable(msg.sender).transfer(_amount);
   }


}

//SPDX-License-Identifier: MIT
pragma solidity >=0.8.12 <0.9.0;

//Import required contracts
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

interface IParkToken is IERC20{

     function getPrivateSaleStatus() external view returns(bool);
     function getLotteryLaunchStatus() external view returns(bool);
     function isInternalWallets(address sender_) external view returns(bool);

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}