// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./interface/IERCOwnable.sol";
import "./interface/IwrappedToken.sol";
import "./interface/Iregistry.sol";
import "./interface/Isettings.sol";
import "./interface/IbridgeMigrator.sol";
import "./interface/Icontroller.sol";
import "./interface/Ideployer.sol";
import "./interface/IfeeController.sol";
import "./interface/IbridgePool.sol";



contract Bridge is Context , ReentrancyGuard {
    
    struct asset {
        address tokenAddress; 
        uint256 minAmount;
        uint256 maxAmount;
        uint256 feeBalance;
        uint256 collectedFees;
        bool ownedRail;
        address manager;
        address feeRemitance;
        uint256 balance;
        bool isSet;
   }
   struct directForiegnAsset {
          address foriegnAddress;
          address nativeAddress;
          uint256 chainID;
          bool isSet;
   }

   IController public controller;
   Isettings public settings;
   IRegistery public registry;
   IbridgePool public bridgePool;
   bool public paused;
   address[]  public nativeAssetsList;
   mapping(address => asset) public nativeAssets;
   mapping(address => bool) public isActiveNativeAsset;
   mapping(address => uint256[])  assetSupportedChainIds;
   mapping(address => mapping(uint256 => bool)) public  isAssetSupportedChain;
   mapping(address => uint256 ) public foriegnAssetChainID;
   mapping(address => asset) public foriegnAssets;
   mapping(uint256 => directForiegnAsset) public directForiegnAssets;
   mapping(address => mapping(uint256 => address)) public wrappedForiegnPair;
   mapping(address => address) public foriegnPair;
   mapping(address => mapping(uint256 => bool)) public hasWrappedForiegnPair;
   uint256 public totalFees;
   uint256 public feeBalance;
   uint256 public  chainId; // current chain id
//    uint256 public immutable chainId; // current chain id 
   address public deployer  ;
   address public feeController;
   bool public activeMigration;
   uint256 public migrationInitiationTime;
   uint256 public constant migrationDelay = 2 days;
   address public newBridge;
   address public  migrator;

   uint256 public directForiegnCount;
//    address public immutable migrator;
   uint256 public fMigrationAt;
   uint256 public fDirectSwapMigrationAt;
   uint256 public nMigrationAt;
   address[] public foriegnAssetsList;

   mapping(address => mapping(uint256 =>  bool)) public isDirectSwap;
   event MigrationInitiated(address indexed newBridge);
   event RegisterredNativeMigration(address indexed assetAddress);
   event RegisteredForiegnMigration(address indexed foriegnAddress, uint256 indexed chainID, address indexed wrappedAddress);
   event MigratedAsset(address indexed assetAddress , bool isNativeAsset);
   event ForiegnAssetAdded(address indexed foriegnAddress , uint256 indexed chainID ,address indexed  wrappedAddress);
   event updatedAddresses(address indexed settings , address indexed feeController , address indexed deployer);
   event MigrationCompleted(address indexed newBridge);
   event BridgePauseStatusChanged(bool status);
//    event NativeAssetStatusChanged(address indexed assetAddress , bool status);
   event AssetManagerUpdated(
       address indexed assetAddress,
       bool isNativeAsset,
       address indexed previousManager,
       address indexed newManager
    );
    event AssetFeeRemitanceUpdated(
       address indexed assetAddress,
       bool isNativeAsset,
       address indexed prevFeeRemitance,
       address indexed newFeeRemitance
    );
   event SendTransaction(
       bytes32 transactionID, 
       uint256 chainID,
       address indexed assetAddress,
       uint256 sendAmount,
       address indexed receiver,
       uint256 nounce,
       address indexed  sender
    );
   event BurnTransaction(
       bytes32 transactionID,
       uint256 chainID,
       address indexed assetAddress,
       uint256 sendAmount,
       address indexed receiver,
       uint256 nounce,
       address indexed  sender
    );
   event RailAdded(
       address indexed assetAddress,
       uint256 minAmount,
       uint256 maxAmount,
       uint256[] supportedChains,
       address[] foriegnAddresses,
       bool directSwap,
       address  registrar,
       bool ownedRail,address indexed manager,
       address  feeRemitance,
       uint256 deployWith
    );
    event AssetLimitUpdated(
        address indexed assetAddress,
        bool isNativeAsset,
        uint256 oldMin,
        uint256 newMin,
        uint256 oldMax,
        uint256 newMax
    );


   constructor (address _controllers , address _settings, address _registry, address _deployer ,address _feeController , address _bridgePool,address _migrator) {
       noneZeroAddress(_controllers);
       noneZeroAddress(_settings);
       noneZeroAddress(_registry);
       noneZeroAddress(_deployer);
       noneZeroAddress(_feeController);
       noneZeroAddress(_bridgePool);
       settings = Isettings(_settings);
       controller = IController(_controllers);
       registry = IRegistery(_registry);
       migrator = _migrator;
       deployer = _deployer;
       feeController = _feeController;
       bridgePool = IbridgePool(_bridgePool);
       uint256 id;
       assembly {
        id := chainid()
    }
    chainId = id;
   }
  


  function pauseBrigde() external {
      isOwner();
      paused = !paused;
    //    emit BridgePauseStatusChanged(paused);
  }


   function updateAddresses(address _settings , address _feeController ,  address _deployer) external {
       isOwner();
       noneZeroAddress(_settings) ;
       noneZeroAddress(_feeController);
       noneZeroAddress(_deployer);
       emit updatedAddresses(_settings , _feeController , _deployer);
       settings = Isettings(_settings);
       feeController = _feeController;
       deployer = _deployer;

   }




    function activeNativeAsset(address assetAddress , bool activate) public {
       require(nativeAssets[assetAddress].isSet , "I_A");
        require(controller.isAdmin(_msgSender())  || controller.isRegistrar(_msgSender()) ||  isAssetManager(assetAddress, true),"U_A");
    //    emit NativeAssetStatusChanged(assetAddress , activate);
       isActiveNativeAsset[assetAddress] = activate;

   }


   function updateAsset(address assetAddress , address manager ,address _feeRemitance, uint256 min , uint256 max) external {
        notPaused();
        noneZeroAddress(manager);  
        noneZeroAddress(_feeRemitance);
        asset memory currentAsset;
        bool native;
        if (isAssetManager(assetAddress ,true)) {
            currentAsset = nativeAssets[assetAddress];
            native = true;  
        } else if (isAssetManager(assetAddress ,false)) {
            currentAsset = foriegnAssets[assetAddress]; 
        } else {
            require(false, "U_A");
        }

        if(currentAsset.manager != manager){
            emit AssetManagerUpdated(assetAddress , native , currentAsset.manager , manager);
            currentAsset.feeRemitance = manager;
        }
        if(currentAsset.feeRemitance != _feeRemitance){
            emit AssetFeeRemitanceUpdated(
                assetAddress,
                native,
                currentAsset.feeRemitance,
                _feeRemitance
            );
            currentAsset.feeRemitance = _feeRemitance;
        }
        if(currentAsset.minAmount != min || currentAsset.maxAmount != max){
            emit AssetLimitUpdated(
                assetAddress,
                native,
                currentAsset.minAmount,
                min,
                currentAsset.maxAmount,
                max
            );
            currentAsset.minAmount = min;
            currentAsset.maxAmount = max;  
            }
   }



   function registerRail(
      address assetAddress , 
      uint256 minAmount, 
      uint256 maxAmount,
      uint256[] calldata supportedChains,
      address[] calldata foriegnAddresses,
      bool directSwap,
      address feeAccount, 
      address manager,
      uint256 deployWith
    ) 
    external  
    {
          notPaused();
          bool ownedRail;
          
          require(maxAmount > minAmount && minAmount > 0  && supportedChains.length == foriegnAddresses.length, "AL_E");
     
         
          if (controller.isAdmin(msg.sender)) {
              if (manager != address(0)  && feeAccount != address(0)) {
                  ownedRail = true;
              }
          } else {
              ownedRail = true;
              if (settings.onlyOwnableRail()) {
              require( _msgSender() == IERCOwnable(assetAddress).owner() || settings.approvedToAdd(assetAddress , msg.sender), "U_A");
              }
              IERC20 token = IERC20(settings.brgToken());
              require(token.transferFrom(_msgSender() , settings.feeRemitance() , supportedChains.length * settings.railRegistrationFee()), "I_F");
            }
            
            _registerRail(assetAddress, supportedChains, directSwap, minAmount, maxAmount, ownedRail , feeAccount, manager , false);
            emit RailAdded(
            assetAddress,
            minAmount,
            maxAmount,
            supportedChains,
            foriegnAddresses,
            directSwap,
            _msgSender(),
            ownedRail,
            manager,
            feeAccount,
            deployWith
        );
     
    }

   function _registerRail(
       address assetAddress,
       uint256[] memory supportedChains,
      bool directSwap,
      uint256 minAmount, 
      uint256 maxAmount,
      bool ownedRail, 
      address feeAccount, 
      address manager,
      bool migration
   )
    internal
   {
        asset storage newNativeAsset = nativeAssets[assetAddress];
       if (!newNativeAsset.isSet ) {
           newNativeAsset.tokenAddress = assetAddress;
           newNativeAsset.minAmount = minAmount;
           newNativeAsset.maxAmount = maxAmount;
           if (ownedRail) {
               if(feeAccount != address(0) && manager != address(0) ){
                   newNativeAsset.ownedRail = true;
                    newNativeAsset.feeRemitance = feeAccount;
                    newNativeAsset.manager = manager;
               }
               
            }
            newNativeAsset.isSet = true;
            isActiveNativeAsset[assetAddress] = false;
            nativeAssetsList.push(assetAddress);
            
       }
       if (directSwap && !bridgePool.validPool(assetAddress)) {
                bridgePool.createPool(assetAddress , maxAmount);
       }
       for (uint256 index; index < supportedChains.length ; index++) {
           if (settings.isNetworkSupportedChain(supportedChains[index])) {
               if (!isAssetSupportedChain[assetAddress][supportedChains[index]] ) {
                isAssetSupportedChain[assetAddress][supportedChains[index]] = true;
                assetSupportedChainIds[assetAddress].push(supportedChains[index]);
                if(migration){
                    if (IbridgeMigrator(migrator).isDirectSwap(assetAddress , supportedChains[index])) {
                         isDirectSwap[assetAddress][supportedChains[index]] = true;
                      }
                } else {

                    if (directSwap) {
                        isDirectSwap[assetAddress][supportedChains[index]] = true;
                     }
                }
                
               }  
           }
          
       }
        
   }


   function addForiegnAsset(
       address foriegnAddress,
       uint256 chainID,
       uint256[] calldata range,
       string[] calldata assetMeta,
       bool OwnedRail,
       address manager,
       address feeAddress,
       uint256 deployWith,
       bool directSwap,
       address nativeAddress
    ) 
       external 
    {
       
       require(controller.isAdmin(_msgSender()) || controller.isRegistrar(_msgSender()) ,'U_A_r');
       require(settings.isNetworkSupportedChain(chainID) && !hasWrappedForiegnPair[foriegnAddress][chainID] && range.length == 2 && assetMeta.length == 2 , "registered");

      address wrappedAddress;
       if(directSwap){
           wrappedAddress = nativeAddress;
           isDirectSwap[foriegnAddress][chainID] = true;
           directForiegnAssets[directForiegnCount] = directForiegnAsset(foriegnAddress , wrappedAddress , chainID, true);
           directForiegnCount++;
       }
       else{
        wrappedAddress =  Ideployer(deployer).deployerWrappedAsset(assetMeta[0] , assetMeta[1], deployWith);
       foriegnAssets[wrappedAddress] = asset(wrappedAddress , range[0], range[1] , 0 ,0,OwnedRail , manager,feeAddress  , 0, true);
       foriegnAssetChainID[wrappedAddress] = chainID;
       foriegnPair[wrappedAddress] = foriegnAddress;
       foriegnAssetsList.push(wrappedAddress);
       }
    
       _registerForiegn(foriegnAddress, chainID, wrappedAddress);
   }

   function _registerForiegn(address foriegnAddress, uint256 chainID,address wrappedAddress) internal {
       wrappedForiegnPair[foriegnAddress][chainID] =  wrappedAddress;
       hasWrappedForiegnPair[foriegnAddress][chainID] = true;
       emit ForiegnAssetAdded(foriegnAddress , chainID , wrappedAddress);

   }
   function send(uint256 chainTo ,  address assetAddress , uint256 amount ,  address receiver ) external payable nonReentrant returns (bytes32 transactionID) {
       notPaused();
    //    require(, "C_E");
       require(isActiveNativeAsset[assetAddress] && isAssetSupportedChain[assetAddress][chainTo]  && amount  >= nativeAssets[assetAddress].minAmount  && amount  <= nativeAssets[assetAddress].maxAmount , "AL_E");
       noneZeroAddress(receiver);
       (bool success, uint256 recievedValue) =  processedPayment(assetAddress ,chainTo, amount);
       require(success && recievedValue > 0 , "I_F");
       deductFees(assetAddress , chainTo , true);
       if(isDirectSwap[assetAddress][chainTo]){
           if(assetAddress == address(0)){
               bridgePool.topUp{ value : recievedValue}(assetAddress , recievedValue);
           }else {
               IERC20(assetAddress).approve(address(bridgePool), recievedValue);
               bridgePool.topUp(assetAddress , recievedValue);
           }
       }
       uint256 nounce = registry.getUserNonce(receiver);
       transactionID =  keccak256(abi.encodePacked(
                chainId,
                chainTo,
                assetAddress,
                amount,
                receiver,
                nounce 
            ));
      
      registry.registerTransaction(transactionID ,chainTo , assetAddress , recievedValue , receiver , nounce , 0);
      nativeAssets[assetAddress].balance += recievedValue;
     
        emit SendTransaction(
            transactionID,
            chainTo,
            assetAddress,
            amount,
            receiver,
            nounce,
            msg.sender
        );
   
   }


   function burn( address assetAddress , uint256 amount ,  address receiver) external payable  nonReentrant returns (bytes32 transactionID){
       notPaused();
       uint256 chainTo = foriegnAssetChainID[assetAddress];
       require(foriegnAssets[assetAddress].isSet && amount  >= foriegnAssets[assetAddress].minAmount && amount  <= foriegnAssets[assetAddress].maxAmount , "AL_E");
       noneZeroAddress(receiver);
        (bool success, uint256 recievedValue) =  processedPayment(assetAddress ,chainTo, amount);
       require(success && recievedValue > 0 , "I_F");
       deductFees(assetAddress ,chainTo , false);
       IwrappedToken(assetAddress).burn(recievedValue);
       address _foriegnAsset = foriegnPair[assetAddress];
       uint256 nounce = registry.getUserNonce(receiver);
       transactionID =  keccak256(abi.encodePacked(
            chainId,
            chainTo,
            _foriegnAsset,
            recievedValue,
            receiver,
            nounce
        ));

        registry.registerTransaction(transactionID ,chainTo , _foriegnAsset ,recievedValue , receiver ,nounce, 1);

        emit BurnTransaction(
            transactionID,
            chainTo,
            _foriegnAsset,
            recievedValue,
            receiver,
            nounce,
            msg.sender
        );
    }
   
  
   function mint(bytes32 mintID) public  nonReentrant { 
       notPaused();
    //    require(, "MI_E");
       IRegistery.Transaction memory transaction = registry.mintTransactions(mintID);
       require(registry.isMintTransaction(mintID) && !transaction.isCompleted && registry.transactionValidated(mintID), "M");
       if (isDirectSwap[transaction.assetAddress][transaction.chainId]) {
           bridgePool.sendOut(transaction.assetAddress, transaction.receiver , transaction.amount);
       } else {
           IwrappedToken(transaction.assetAddress).mint(transaction.receiver , transaction.amount);
       }
       
       registry.completeMintTransaction(mintID);
   }


   function claim(bytes32 claimID) public  nonReentrant {
       notPaused();
    //    require( , "CI_E");
       IRegistery.Transaction memory transaction = registry.claimTransactions(claimID);
       require(registry.isClaimTransaction(claimID) && registry.assetChainBalance(transaction.assetAddress,transaction.chainId) >= transaction.amount  && !transaction.isCompleted && registry.transactionValidated(claimID) ,"AL_E");
    //    require(, "C");
    //    require(, "N_V");
       payoutUser(payable(transaction.receiver), transaction.assetAddress , transaction.amount);
       nativeAssets[transaction.assetAddress].balance -= transaction.amount;
       registry.completeClaimTransaction(claimID);
   }


   function payoutUser(address payable recipient , address _paymentMethod , uint256 amount) private {
       noneZeroAddress(recipient);
        if (_paymentMethod == address(0)) {
          recipient.transfer(amount);
        } else {
             IERC20 currentPaymentMethod = IERC20(_paymentMethod);
             require(currentPaymentMethod.transfer(recipient , amount) ,"I_F");
        }
    }


    // internal fxn used to process incoming payments 
    function processedPayment(address assetAddress ,uint256 chainID, uint256 amount) internal returns (bool , uint256) {
        uint256 fees = IfeeController(feeController).getBridgeFee(msg.sender, assetAddress, chainID);
        if (assetAddress == address(0)) {
            if(msg.value >= amount + fees){
                uint256 value = msg.value - fees;
                return (true , value);
            } else {
                return (false , 0);
            }
            
        } else {
            IERC20 token = IERC20(assetAddress);
            if (token.allowance(_msgSender(), address(this)) >= amount && (msg.value >=  fees)) {
                uint256 balanceBefore = token.balanceOf(address(this));
                require(token.transferFrom(_msgSender() , address(this) , amount), "I_F");
                uint256 balanceAfter = token.balanceOf(address(this));
               return (true , balanceAfter - balanceBefore);
            } else {
                return (false , 0);
            }
        }
    }


   // internal fxn for deducting and remitting fees after a sale
    function deductFees(address assetAddress , uint256 chainID , bool native) private {
            asset storage currentasset;
            if(native)
                currentasset = nativeAssets[assetAddress];
            else
                currentasset = foriegnAssets[assetAddress];
            
            require(currentasset.isSet ,"I_A");

            // uint256 fees_to_deduct = settings.networkFee(chainID);
            uint256 fees_to_deduct = IfeeController(feeController).getBridgeFee(msg.sender, assetAddress, chainID ) ;
            totalFees = totalFees + fees_to_deduct;
        
            if (currentasset.ownedRail) {
            uint256 ownershare = fees_to_deduct * settings.railOwnerFeeShare() / 100;
            uint256 networkshare = fees_to_deduct - ownershare;
            currentasset.collectedFees += fees_to_deduct;
            currentasset.feeBalance += ownershare;
            feeBalance = feeBalance + networkshare;

            } else {
                currentasset.collectedFees += fees_to_deduct;
                feeBalance = feeBalance + fees_to_deduct;
            }
            
            if (feeBalance > settings.minWithdrawableFee()) {
                if (currentasset.ownedRail) {
                    if (currentasset.feeBalance > 0) {
                        payoutUser(payable(currentasset.feeRemitance), address(0), currentasset.feeBalance );
                        currentasset.feeBalance = 0;
                    }
                }
                if (feeBalance > 0) {
                    payoutUser(payable(settings.feeRemitance()), address(0), feeBalance );
                    feeBalance = 0;
                    //recieve excess fees
                    if(address(this).balance > nativeAssets[address(0)].balance ){
                        uint256 excess = address(this).balance - nativeAssets[address(0)].balance;
                        payoutUser(payable(settings.feeRemitance()), address(0), excess );
                    } 
                    
                }
            }
     }


    function initialMigration(address _newbridge) external {
        notPaused();
        isOwner();
        noneZeroAddress(_newbridge);
        require( !activeMigration , "P_M");
        newBridge = _newbridge;
        activeMigration = true;
        paused = true;
        migrationInitiationTime = block.timestamp;
        emit MigrationInitiated(_newbridge);
    }


    function completeMigration() external {
        isOwner();
        
        require (activeMigration  && nMigrationAt >= nativeAssetsList.length && fMigrationAt >= foriegnAssetsList.length  && fDirectSwapMigrationAt >= directForiegnCount, "P_M");
        registry.transferOwnership(newBridge);
        activeMigration = false;
        emit MigrationCompleted(newBridge);
    }

    
    function migrateForiegn(uint256 limit , bool directSwap) external { 
        isOwner();
        require (activeMigration && block.timestamp - migrationInitiationTime >= migrationDelay , "N_Y_T");
        uint256 start ;
        uint256 migrationAmount;
        if(directSwap  ) {
            require(directForiegnCount > fDirectSwapMigrationAt ,"completed");
            if (fDirectSwapMigrationAt == 0)
                start = fDirectSwapMigrationAt;
            else 
                start = fDirectSwapMigrationAt + 1;
        
            if(limit + fDirectSwapMigrationAt < directForiegnCount)
                migrationAmount = limit;
            else 
                migrationAmount = directForiegnCount - fDirectSwapMigrationAt;

            for (uint256 i; i < migrationAmount ; i++) { 
                directForiegnAsset storage directSwapAsset = directForiegnAssets[fDirectSwapMigrationAt + i];
                if(directSwapAsset.isSet){
                IbridgeMigrator(newBridge).registerForiegnMigration(
                    directSwapAsset.foriegnAddress,
                    directSwapAsset.chainID,
                    0,
                    0,
                    false,
                    address(0),
                    address(0),
                    0,
                    true,
                    directSwapAsset.nativeAddress
                    ); 
                    fDirectSwapMigrationAt = fDirectSwapMigrationAt + 1;
                    // emit MigratedAsset(directSwapAsset.foriegnAddress , false);
                }
            }
            
        } else {
            require(foriegnAssetsList.length > fMigrationAt ,"completed");
            if (fMigrationAt == 0)
                start = fMigrationAt;
            else 
                start = fMigrationAt + 1;

            if(limit + fMigrationAt < foriegnAssetsList.length)
                migrationAmount = limit;
            else 
                migrationAmount = foriegnAssetsList.length - fMigrationAt;
           
            for (uint256 i; i < migrationAmount ; i++) { 
                address assetAddress = foriegnAssetsList[start+i];
                asset memory foriegnAsset = foriegnAssets[assetAddress];
                if (foriegnAsset.ownedRail) {
                    if (foriegnAsset.feeBalance > 0) {
                        payoutUser(payable(foriegnAsset.feeRemitance), address(0), foriegnAsset.feeBalance );
                        foriegnAsset.feeBalance = 0;
                    }
                }
                IwrappedToken(assetAddress).transferOwnership(newBridge);
                IbridgeMigrator(newBridge).registerForiegnMigration(
                    foriegnAsset.tokenAddress,
                    foriegnAssetChainID[foriegnAsset.tokenAddress],
                    foriegnAsset.minAmount,
                    foriegnAsset.maxAmount,
                    foriegnAsset.ownedRail,
                    foriegnAsset.manager,
                    foriegnAsset.feeRemitance,
                    foriegnAsset.collectedFees,
                    false,
                    foriegnPair[foriegnAsset.tokenAddress]
                    );
                    
                fMigrationAt = fMigrationAt + 1;
                // emit MigratedAsset(assetAddress , false);
            }
        }
        
    }


   function migrateNative(uint256 limit) external {
       isOwner();
        require (activeMigration && block.timestamp - migrationInitiationTime >= migrationDelay , "N_Y_T");
        uint256 migrationAmount;
        uint256 start;
        if (nMigrationAt == 0)
            start = nMigrationAt;
        else 
            start = nMigrationAt + 1;
        if (limit == 0) {
            migrationAmount = nativeAssetsList.length - nMigrationAt;
        } else {
            migrationAmount = limit;
            require(migrationAmount + nMigrationAt <= nativeAssetsList.length ,"M_O");
        }
        
        
        for (uint256 i; i < migrationAmount ; i++) {
             _migrateNative(nativeAssetsList[start+i]);
        }
            
            // emit MigratedAsset(assetAddress , true);
        
    }

    function _migrateNative(address assetAddress) internal {
         
            asset memory nativeAsset = nativeAssets[assetAddress];
           uint256 balance;
           if(assetAddress == address(0)){
               balance = address(this).balance;
                IbridgeMigrator(newBridge).registerNativeMigration{value: balance}(
                assetAddress,
                [nativeAsset.minAmount,nativeAsset.maxAmount],
                nativeAsset.collectedFees,
                nativeAsset.ownedRail,
                nativeAsset.manager,
                nativeAsset.feeRemitance,
                [nativeAsset.balance, balance , nativeAsset.feeBalance] ,
                isActiveNativeAsset[assetAddress],
                assetSupportedChainIds[assetAddress]
                );
                
           }else {
               balance = IERC20(assetAddress).balanceOf(address(this));
                IERC20(assetAddress).approve(newBridge, balance);
                IbridgeMigrator(newBridge).registerNativeMigration(
                assetAddress,
                [nativeAsset.minAmount,nativeAsset.maxAmount],
                nativeAsset.collectedFees,
                nativeAsset.ownedRail,
                nativeAsset.manager,
                nativeAsset.feeRemitance,
                [nativeAsset.balance, balance , nativeAsset.feeBalance],
                isActiveNativeAsset[assetAddress],
                assetSupportedChainIds[assetAddress]
                );
           }
           nMigrationAt = nMigrationAt + 1;
    }
    function registerNativeMigration(
        address assetAddress,
        uint256[2] memory limits,
        uint256  collectedFees,
        bool ownedRail,
        address manager,
        address feeRemitance,
        uint256[3] memory balances,
        bool active,
        uint256[] memory supportedChains
    )   
        external
        payable 
    {
        require( !nativeAssets[assetAddress].isSet && _msgSender() == migrator  , "U_A");
        
        (bool success, uint256 amountRecieved) = processedPayment(assetAddress , 0, balances[1]);
        require(success && amountRecieved >= balances[1], "I_F");
        _registerRail(assetAddress, supportedChains, false, limits[0], limits[1], ownedRail , feeRemitance, manager , true);
        nativeAssets[assetAddress].balance = balances[0];
        nativeAssets[assetAddress].feeBalance = balances[2];
        nativeAssets[assetAddress].collectedFees = collectedFees;

        if (active) {
            isActiveNativeAsset[assetAddress] = true;
        }
        //  emit RegisterredNativeMigration(assetAddress);
    }


   function registerForiegnMigration(
       address foriegnAddress, 
       uint256 chainID, 
       uint256 minAmount,
       uint256 maxAmount,
       bool ownedRail, 
       address manager,
       address feeAddress,
       uint256  _collectedFees,
       bool directSwap,
       address wrappedAddress
    )  
       external 
    {
        // require(settings.isNetworkSupportedChain(chainID) && !hasWrappedForiegnPair[foriegnAddress][chainID] , "A_R");
        require(settings.isNetworkSupportedChain(chainID) && !hasWrappedForiegnPair[foriegnAddress][chainID] && _msgSender() == migrator &&  wrappedAddress != address(0) , "U_A");
        
              if(directSwap){
                    isDirectSwap[foriegnAddress][chainID] = true;
                    directForiegnAssets[directForiegnCount] = directForiegnAsset(foriegnAddress , wrappedAddress , chainID, true);
                    directForiegnCount++;
                }
                else{
                foriegnAssets[wrappedAddress] = asset(
                    wrappedAddress,
                    minAmount,
                    maxAmount,
                    0,
                    _collectedFees,
                    ownedRail,
                    manager,
                    feeAddress,
                    0,
                    true);    
                foriegnAssetChainID[wrappedAddress] = chainID;
                foriegnPair[wrappedAddress] = foriegnAddress;
                foriegnAssetsList.push(wrappedAddress);
                }
    
                _registerForiegn(foriegnAddress, chainID, wrappedAddress);

            
        // emit RegisteredForiegnMigration(foriegnAddress , chainID, wrappedAddress);

   }

   function getID(
       uint256 chainFrom,
       uint256 chainTo,
       address assetAddress,
       uint256 amount,
       address receiver,
       uint256 nounce
   )
       public
       pure
       returns (bytes32)  
  {
       return  keccak256(abi.encodePacked(chainFrom, chainTo , assetAddress , amount, receiver, nounce));
  }
   

   function assetLimits(address assetAddress , bool native) external view returns (uint256 , uint256 ) {
       if (native)
            return (nativeAssets[assetAddress].minAmount, nativeAssets[assetAddress].maxAmount);
       else
            return (foriegnAssets[assetAddress].minAmount, foriegnAssets[assetAddress].maxAmount);
   }


   function getAssetSupportedChainIds(address assetAddress) external view returns(uint256[] memory) {
       return assetSupportedChainIds[assetAddress];
   }


   function getAssetCount() external view returns (uint256 native , uint256 foriegn) {
        native =  nativeAssetsList.length;
       foriegn = foriegnAssetsList.length;
   }

   function notPaused()internal view returns (bool) {
        require(!paused, "B_P");
        return true;        
    }


    function noneZeroAddress(address _address) internal pure returns (bool) {
        require(_address != address(0), "A_z");
        return true;
   }



    function onlyAdmin() internal view returns (bool) {
        require(controller.isAdmin(msg.sender) || msg.sender == controller.owner() ,"U_A");
        return true;
    }


    function isOwner() internal view returns (bool) {
        require(controller.owner() == _msgSender() , "U_A");
        return true;
    }

     
    function isAssetManager(address assetAddress ,bool native)  internal view returns (bool) {
        bool isManager;
        if (native) {
            if(nativeAssets[assetAddress].manager == _msgSender()  && nativeAssets[assetAddress].manager != address(0)){
                isManager = true;
            } 
        } 
            
        else {
            if(foriegnAssets[assetAddress].manager == _msgSender()  && foriegnAssets[assetAddress].manager != address(0)){
                isManager = true;
            } 

        }

        return isManager;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Spend `amount` form the allowance of `owner` toward `spender`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

interface IERCOwnable {
     function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
    
     function owner() external view  returns (address);
    }

// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

interface IwrappedToken {
     function transferOwnership(address newOwner) external;

     function owner() external returns(address);

     function burn(uint256 amount) external ;
     
     function mint(address account , uint256 amount) external ;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

interface IRegistery {
    struct Transaction{
            uint256 chainId;
            address assetAddress;
            uint256 amount;
            address receiver;
            uint256 nounce;
            bool  isCompleted;
        }

    function getUserNonce(address user) external returns (uint256);
    function isSendTransaction(bytes32 transactionID) external returns (bool);
    function isClaimTransaction(bytes32 transactionID) external returns (bool);
    function isMintTransaction(bytes32 transactionID) external returns (bool);
    function isburnTransactio(bytes32 transactionID) external returns (bool);
    function transactionValidated(bytes32 transactionID) external returns (bool);
    function assetChainBalance(address asset, uint256 chainid) external returns (uint256);

    function sendTransactions(bytes32 transactionID) external returns (Transaction memory);
    function claimTransactions(bytes32 transactionID) external returns (Transaction memory);
    function burnTransactions(bytes32 transactionID) external returns (Transaction memory);
    function mintTransactions(bytes32 transactionID) external returns (Transaction memory);
    
    function completeSendTransaction(bytes32 transactionID) external;
    function completeBurnTransaction(bytes32 transactionID) external;
    function completeMintTransaction(bytes32 transactionID) external;
    function completeClaimTransaction(bytes32 transactionID) external;
    function transferOwnership(address newOwner) external;
    
  
    function registerTransaction(
       bytes32 transactionID,
       uint256 chainId,
       address assetAddress,
       uint256 amount,
       address receiver,
       uint256 nounce,
       uint8 _transactionType
     ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

interface Isettings {

    function networkFee(uint256 chainId) external view returns (uint256);

    function minValidations() external view returns (uint256);
    
    function isNetworkSupportedChain(uint256 chainID) external view returns (bool);

    function feeRemitance() external view returns (address);

    function railRegistrationFee() external view returns (uint256);

    function railOwnerFeeShare() external view returns (uint256);

    function onlyOwnableRail() external view returns (bool);

    function updatableAssetState() external view returns (bool);

    function minWithdrawableFee() external view returns (uint256);

    function brgToken() external view returns (address);

    function getNetworkSupportedChains() external view returns(uint256[] memory);
    
    function approvedToAdd(address token , address user) external view returns(bool);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

interface IbridgeMigrator {
   function isDirectSwap(address assetAddress , uint256 chainID) external returns (bool);
function registerNativeMigration(
         address assetAddress,
        uint256[2] memory limits,
        uint256  collectedFees,
        bool ownedRail,
        address manager,
        address feeRemitance,
        uint256[3] memory balances,
        bool active,
        uint256[] memory supportedChains
         ) external payable;


function registerForiegnMigration(
       address foriegnAddress, 
       uint256 chainID, 
       uint256 minAmount,
       uint256 maxAmount,
       bool ownedRail, 
       address manager,
       address feeAddress,
       uint256  _collectedFees,
       bool directSwap,
       address wrappedAddress
   ) external ;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

interface IController {

    function isAdmin(address account) external view returns (bool);


    function isRegistrar(address account) external view returns (bool);


    function isOracle(address account) external view returns (bool);


    function isValidator(address account) external view returns (bool);


    function owner() external view returns (address);

    
    function validatorsCount() external view returns (uint256);

    function settings() external view returns (address);


    function deployer() external view returns (address);


    function feeController() external view returns (address);

    
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.0;

interface Ideployer {

  function  deployerWrappedAsset(string calldata _name , string calldata _symbol, uint256 lossless) external returns (address);
  
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.0;

interface IfeeController {
    function getBridgeFee(address sender, address asset, uint256 chainTo ) external view returns (uint256);

}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;


interface IbridgePool {

     function validPool(address poolAddress) external view returns (bool);
     function topUp(address poolAddress, uint256 amount) external payable;
     function sendOut(address poolAddress , address receiver , uint256 amount) external;
     function createPool(address poolAddress, uint256 debtThreshold) external;
    
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
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}