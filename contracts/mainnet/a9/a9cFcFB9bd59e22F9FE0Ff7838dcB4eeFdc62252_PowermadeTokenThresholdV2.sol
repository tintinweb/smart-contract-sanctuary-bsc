/**
 *Submitted for verification at BscScan.com on 2022-12-14
*/

/***
 *    ██████╗  ██████╗ ██╗    ██╗███████╗██████╗ ███╗   ███╗ █████╗ ██████╗ ███████╗
 *    ██╔══██╗██╔═══██╗██║    ██║██╔════╝██╔══██╗████╗ ████║██╔══██╗██╔══██╗██╔════╝
 *    ██████╔╝██║   ██║██║ █╗ ██║█████╗  ██████╔╝██╔████╔██║███████║██║  ██║█████╗  
 *    ██╔═══╝ ██║   ██║██║███╗██║██╔══╝  ██╔══██╗██║╚██╔╝██║██╔══██║██║  ██║██╔══╝  
 *    ██║     ╚██████╔╝╚███╔███╔╝███████╗██║  ██║██║ ╚═╝ ██║██║  ██║██████╔╝███████╗
 *    ╚═╝      ╚═════╝  ╚══╝╚══╝ ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝╚═════╝ ╚══════╝
 *    ███████╗ ██████╗ ██████╗ ███████╗██╗   ██╗███████╗████████╗███████╗███╗   ███╗
 *    ██╔════╝██╔════╝██╔═══██╗██╔════╝╚██╗ ██╔╝██╔════╝╚══██╔══╝██╔════╝████╗ ████║
 *    █████╗  ██║     ██║   ██║███████╗ ╚████╔╝ ███████╗   ██║   █████╗  ██╔████╔██║
 *    ██╔══╝  ██║     ██║   ██║╚════██║  ╚██╔╝  ╚════██║   ██║   ██╔══╝  ██║╚██╔╝██║
 *    ███████╗╚██████╗╚██████╔╝███████║   ██║   ███████║   ██║   ███████╗██║ ╚═╝ ██║
 *    ╚══════╝ ╚═════╝ ╚═════╝ ╚══════╝   ╚═╝   ╚══════╝   ╚═╝   ╚══════╝╚═╝     ╚═╝
 *                                                                                  
 */                                                                                                   
// SPDX-License-Identifier: MIT

pragma solidity ^0.5.17;

// Interface of the Powermade Token, that implements also a standard BEP20 interface. Only needed functions are included
interface PowermadeToken {
    // Get the balance
    function balanceOf(address tokenOwner) external view returns (uint balance);
    // Get the pancake router used by the token
    function pancakeRouter() external view returns (address);
}

// Interface for generic token (fungible) or NFT balance + rarity check. In the case of rarity check the NFT must implement ERC721Enumerable and the custom getRarity()
interface ThresholdTokenOrNFT {
    // Get the balance
    function balanceOf(address tokenOwner) external view returns (uint balance);
    // Get the rarity (ONLY COMPATIBLE NFTS), the feature must be enabled
    function getRarity(uint256 tokenId) external view returns (uint8 rarity);
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenID);
}

// Interface of the PancakeSwap Router
// Reduced Interface only for the needed functions
interface IPancakeRouterView {
    function WETH() external pure returns (address);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}

// Interface to access Powermade contract data
interface Powermade {
    // get the owner 
    function ownerWallet() external view returns (address owner);
    // Get info of a package
    function getPackageInfo(uint16 packageID, uint userID) external view returns (uint price, uint duration, bool enabled, bool rebuy_enabled, bool rebuy_before_exp, uint16[] memory prerequisites, uint16[] memory percentages, bool prereq_not_exp, uint totalEarnedPack, uint purchasesCount, uint last_pid);
}

// Interface for the external custom threshold/eligibility for the package and/or for the commissions
interface ExternalEligibilityContract {
    // Functions used to check the eligibility (eg. custom Token/NFT/other thresholds or other logics) 
    // The first one is called when it's required a state update, for example when calling from the payCommissions cycles. The second one is called only to check the status as a view function
    // The ExternalEligibilityContract must implement both
    function isEligibleExt(address user_address, address other_address, uint16 packageID, uint param1, uint8 sourceID) external returns (bool is_eligible);
    function isEligibleExtW(address user_address, address other_address, uint16 packageID, uint param1, uint8 sourceID) external view returns (bool is_eligible);
}

// Custom token threshold for the Powermade packages on registrations
contract PowermadeTokenThresholdV2 is ExternalEligibilityContract {

    // Threshold system configuration
    // Threshold features:
    // If the price becomes 2X the price_threshold --> The PWD threshold for levels 4 and 5 (commissions) is halved and the new price_threshold is doubled
    // If the price becomes 0.75X the price_threshold (if price_threshold > starting_price_threshold)--> The PWD threshold for levels 4 and 5 (commissions) is doubled and the new price_threshold is halved
    // The minimum price_threshold is the starting_price_threshold of 0.5$ - It means that the first change is when the price reaches 1$
    // The PWD thresholds are 2000 PWD for level 5 and 1000 PWD for level 4. No thresholds (0 PWD) for the other levels

    // Constants and algorithm parameters
    uint private constant starting_price_th = 500 * 1e15;       // 0.5 BUSD
    uint private constant upper_factor = 200;                   // 200% = X2 (+100%)
    uint private constant lower_factor = 75;                    // 75% = 0.75X (-25%) 
    uint private constant lev4_PWD_start_th = 1000 * 1e18;      // 1000 PWD
    uint private constant lev5_PWD_start_th = 2000 * 1e18;      // 2000 PWD
    uint private constant update_deadtime = 24 hours;           // Minimum deadtime between price updates

    // Contracts
    Powermade public powermadeContract;                         // The PowermadeAffiliation contract
    PowermadeToken public powermadeToken;                       // The PWD Token contract
    IPancakeRouterView public pancakeRouter;                    // The Pancake Router used by the PWD Token

    // Structures
    struct PackageUnlockConditions {
        bool conditions_enabled;                                // Global enable for the conditions of the package (false, default, bypass all the conditions)
        bool whitelist_enabled;                                 // Define if whitelist mode is enabled
        mapping (address => bool) whitelist;                    // Whitelist 
        address whitelist_manager;                              // Other Wallet that can add users to the whitelist (Powermade owner always can do it). Optional.
        address unlock_asset_1;                                 // First unlock asset (address(0) means disabled)
        uint8 unlock_asset_1_rarity;                            // Rarity threshold (for compatible NFTs). 0 means rarity check disabled. > 0 means at leas 1 of this rarity
        uint asset_1_threshold;                                 // Quantity (units for NFTs, or wei for tokens) threshold asset 1 (rarity not considered)
        address unlock_asset_2;                                 // Second unlock asset (address(0) means disabled)
        uint8 unlock_asset_2_rarity;                            // Rarity threshold (for compatible NFTs). 0 means rarity check disabled. > 0 means at leas 1 of this rarity
        uint asset_2_threshold;                                 // Quantity (units for NFTs, or wei for tokens) threshold asset 2 (rarity not considered)
        uint busd_pegged_pwd_threshold;                         // BUSD pegged dynamic threshold (0 means feature disabled). Value in BUSD equivalent (wei)
    }

    // Storage variables
    mapping (uint16 => PackageUnlockConditions) public package_buy_unlock_conditions;      // Unlock conditions for the package BUY (configurable)
    uint public price_threshold = starting_price_th;            // The current price threshold (BUSD)
    uint public lev4_PWD_threshold = lev4_PWD_start_th;         // The current PWD threshold for LV4
    uint public lev5_PWD_threshold = lev5_PWD_start_th;         // The current PWD threshold for LV5
    uint public last_price;                                     // Last price of the PWD token (in BUSD)
    uint public last_update_checkpoint;                         // The last update timestamp
    address public price_reference_token;                       // The BUSD token
    address private wbnb_token;                                 // The WBNB token, used for internal calculation

    // Events
    event UpdatedEvent(bool indexed updated_price, bool indexed updated_thresholds, uint checkpoint_ts, uint price_th, uint lev4_PWD_th, uint lev5_PWD_th);
    event AddRemoveWhitelist(address indexed user_address, uint16 indexed packageID, bool indexed add_remove);
    event PackageUnlockConditionsSet(uint16 indexed packageID, bool conditions_enabled);

    
    // Modifier to be used with functions that can be called only by The Owner of the Powermade Main contract
    modifier onlyPowermadeOwner()
    {
        require(msg.sender == Powermade(powermadeContract).ownerWallet(), "Denied");
        _;
    }

    // Modifier to be used with functions that can be called only by The PowermadeAffiliation contract
    modifier onlyPowermadeContract()
    {
        require(msg.sender == address(powermadeContract), "Denied");
        _;
    }

    // Constructor called when deploying
    constructor(address _powermadeAddress, address _powermadeToken, address _BUSD_Token) public {
        powermadeContract = Powermade(_powermadeAddress);
        powermadeToken = PowermadeToken(_powermadeToken);
        pancakeRouter = IPancakeRouterView(powermadeToken.pancakeRouter());
        wbnb_token = pancakeRouter.WETH();
        price_reference_token = _BUSD_Token;
        // Initialize the price and the thresholds
        bool updated_thresholds = true;
        while (updated_thresholds) {
            ( , updated_thresholds) = updatePriceThresholds(true);
        }
    }


    // Function to update the price and the thresholds. If called with is_init=true the time check will be bypassed
    // Usual behavior is to update only every ~24 hours
    function updatePriceThresholds(bool is_init) private returns (bool updated_price, bool updated_thresholds) {
        if (!is_init) {
            // Check if the time passed and we have to do an update
            if (block.timestamp < last_update_checkpoint + update_deadtime) {
                return (false, false);
            }
        }
        // Get the price in BUSD from PancakeSwap, passing from the BNB pool (most of the liquidity)
        address[] memory path = new address[](3);
        path[0] = address(powermadeToken);
        path[1] = wbnb_token;
        path[2] = price_reference_token;
        last_price = pancakeRouter.getAmountsOut(1e18, path)[2];
        updated_price = true;
        // Calculate the thresholds
        if (last_price >= (price_threshold*upper_factor/100)) {
            price_threshold = price_threshold * 2;
            lev4_PWD_threshold = lev4_PWD_threshold / 2;
            lev5_PWD_threshold = lev5_PWD_threshold / 2;
            updated_thresholds = true;
        // NB: If we are in the starting price_threshold (1$/2=0.5$) we don't do anything. We lower the threshold only if price_threshold = 1$, 2$, 4$, 8$, ...
        } else if (price_threshold > starting_price_th && last_price < (price_threshold*lower_factor/100)) {
            price_threshold = price_threshold / 2;
            lev4_PWD_threshold = lev4_PWD_threshold * 2;
            lev5_PWD_threshold = lev5_PWD_threshold * 2;
            updated_thresholds = true;
        }
        // Update checkpoint
        last_update_checkpoint = block.timestamp;
        emit UpdatedEvent(updated_price, updated_thresholds, last_update_checkpoint, price_threshold, lev4_PWD_threshold, lev5_PWD_threshold);
    }


    // Eligibility internal function (view) with error messages
    function isEligibleExtW_Int(address user_address, address, uint16 packageID, uint level, uint8 sourceID) internal view returns (bool is_eligible, string memory err) {
        if (sourceID == 1) {        // Case Package Buy
            // Global condition check enable
            if (!package_buy_unlock_conditions[packageID].conditions_enabled) {
                return (true, "");    // Bypass all conditions. Buy allowed.
            }
            // First check Whitelist mode. If Whitelist enabled but user not whitelisted, return false
            if (package_buy_unlock_conditions[packageID].whitelist_enabled && !package_buy_unlock_conditions[packageID].whitelist[user_address]) {
                return (false, "Not Whitelisted");
            }
            // Check asset 1 
            if (package_buy_unlock_conditions[packageID].unlock_asset_1 != address(0)) {
                ThresholdTokenOrNFT target_token = ThresholdTokenOrNFT(package_buy_unlock_conditions[packageID].unlock_asset_1);
                // Rarity condition (at least 1 of rarity grater that the one specified)
                if (package_buy_unlock_conditions[packageID].unlock_asset_1_rarity > 0) {
                    bool found = false;
                    for (uint j = 0; j < target_token.balanceOf(user_address); j++) {
                        uint tokenID = target_token.tokenOfOwnerByIndex(user_address,j);
                        if (target_token.getRarity(tokenID) >= package_buy_unlock_conditions[packageID].unlock_asset_1_rarity) {
                            found = true;
                            break;
                        }
                    }
                    if (!found) {
                        return (false, "NFT with minimum rarity not found");
                    }
                }
                // Check asset 1 quantity threshold (units for NFTs, or wei for tokens)
                if (target_token.balanceOf(user_address) < package_buy_unlock_conditions[packageID].asset_1_threshold) {
                    return (false, "Asset Amount under threshold");
                }   
            }
            // Check asset 2
            if (package_buy_unlock_conditions[packageID].unlock_asset_2 != address(0)) {
                ThresholdTokenOrNFT target_token = ThresholdTokenOrNFT(package_buy_unlock_conditions[packageID].unlock_asset_2);
                // Rarity condition (at least 1 of rarity grater that the one specified)
                if (package_buy_unlock_conditions[packageID].unlock_asset_2_rarity > 0) {
                    bool found = false;
                    for (uint j = 0; j < target_token.balanceOf(user_address); j++) {
                        uint tokenID = target_token.tokenOfOwnerByIndex(user_address,j);
                        if (target_token.getRarity(tokenID) >= package_buy_unlock_conditions[packageID].unlock_asset_2_rarity) {
                            found = true;
                            break;
                        }
                    }
                    if (!found) {
                        return (false, "NFT with minimum rarity not found");
                    }
                }
                // Check asset 1 quantity threshold (units for NFTs, or wei for tokens)
                if (target_token.balanceOf(user_address) < package_buy_unlock_conditions[packageID].asset_2_threshold) {
                    return (false, "Asset Amount under threshold");
                }   
            }            
            // Check BUSD pegged threshold condition
            if (package_buy_unlock_conditions[packageID].busd_pegged_pwd_threshold > 0) {
                // get last price (or last 24h price) in BUSD and calculate the PWD amount
                uint pwd_threshold = package_buy_unlock_conditions[packageID].busd_pegged_pwd_threshold / last_price;
                if (powermadeToken.balanceOf(user_address) < pwd_threshold) {
                    return (false, "PWD amount under BUSD equivalent threshold");
                }
            }
            // Default return if no lock condition is met
            return (true, "");
        } else if (sourceID == 2) {     // Case sponsor commission (direct)
            return (true, "");
        } else if (sourceID == 3) {     // Case level commission. param1 is the distributed level
            if (level == 4) {
                 if (powermadeToken.balanceOf(user_address) >= lev4_PWD_threshold) {
                     return (true, "");
                 } else {
                     return (false, "");
                 }
            } else if (level == 5) {
                if (powermadeToken.balanceOf(user_address) >= lev5_PWD_threshold) {
                    return (true, "");
                } else {
                    return (false, "");
                }
            } else {
                return (true, "");
            }
        } else {
            return (true, "");
        }
    }

    
    // Implementation of the ExternalEligibilityContract interface (only used parameters). View function.
    function isEligibleExtW(address user_address, address, uint16 packageID, uint level, uint8 sourceID) public view returns (bool is_eligible) {
        (is_eligible, ) = isEligibleExtW_Int(user_address, address(0), packageID, level, sourceID);
    }

    // Implementation of the ExternalEligibilityContract interface (only used parameters). Call function (it can update storage)
    function isEligibleExt(address user_address, address, uint16 packageID, uint level, uint8 sourceID) external onlyPowermadeContract returns (bool is_eligible) {
        // Call the update function
        updatePriceThresholds(false);
        // Return the eligibility
        string memory err;
        (is_eligible, err) = isEligibleExtW_Int(user_address, address(0), packageID, level, sourceID);
        if (sourceID == 1 && is_eligible == false) {        // Case Package Buy and false eligibility (so an error to show to the user)
            revert(err);
        }    
    }


    // Set the Unlock Conditions for the Buy Package operation (when configured)
    function setPackageUnlockConditions(uint16 packageID, bool intelligentUnit, bool conditions_enabled, bool whitelist_enabled, address whitelist_manager, address unlock_asset_1, uint8 unlock_asset_1_rarity, uint asset_1_threshold, address unlock_asset_2, uint8 unlock_asset_2_rarity, uint asset_2_threshold, uint busd_pegged_pwd_threshold) external onlyPowermadeOwner {
        (uint price, , , , , , , , , , ) = powermadeContract.getPackageInfo(packageID, 0);
        require(price > 0, "Package does not exist");
        require(packageID > 1, "Invalid packageID");
        if (intelligentUnit) {
            if (asset_1_threshold > 100 && asset_1_threshold < 1e6) {
                // Probably not NFT and value expressed in human unit 
                asset_1_threshold = asset_1_threshold * 1e18;
            }
            if (asset_2_threshold > 100 && asset_2_threshold < 1e6) {
                // Probably not NFT and value expressed in human unit 
                asset_2_threshold = asset_2_threshold * 1e18;
            }
            if (busd_pegged_pwd_threshold < 1e6) {
                // Probably not in wei format
                busd_pegged_pwd_threshold = busd_pegged_pwd_threshold * 1e18;
            }
        }
        package_buy_unlock_conditions[packageID].conditions_enabled = conditions_enabled;
        package_buy_unlock_conditions[packageID].whitelist_enabled = whitelist_enabled;
        package_buy_unlock_conditions[packageID].whitelist_manager = whitelist_manager;
        package_buy_unlock_conditions[packageID].unlock_asset_1 = unlock_asset_1;
        package_buy_unlock_conditions[packageID].unlock_asset_1_rarity = unlock_asset_1_rarity;
        package_buy_unlock_conditions[packageID].asset_1_threshold = asset_1_threshold;
        package_buy_unlock_conditions[packageID].unlock_asset_2 = unlock_asset_2;
        package_buy_unlock_conditions[packageID].unlock_asset_2_rarity = unlock_asset_2_rarity;
        package_buy_unlock_conditions[packageID].asset_2_threshold = asset_2_threshold;
        package_buy_unlock_conditions[packageID].busd_pegged_pwd_threshold = busd_pegged_pwd_threshold;
        emit PackageUnlockConditionsSet(packageID, conditions_enabled);
    }


    // Manage the whitelist associated to a packageID
    function addRemoveWhitelist(uint16 packageID, address user_address, bool add_remove) external {
        require(msg.sender == Powermade(powermadeContract).ownerWallet() || msg.sender == package_buy_unlock_conditions[packageID].whitelist_manager, "Denied");     // Powermade owner or whitelist manager allowed
        require(package_buy_unlock_conditions[packageID].whitelist_enabled, "Whitelist not enabled for this packageID");
        (uint price, , , , , , , , , , ) = powermadeContract.getPackageInfo(packageID, 0);
        require(price > 0, "Package does not exist");
        require(packageID > 1, "Invalid packageID");
        package_buy_unlock_conditions[packageID].whitelist[user_address] = add_remove;
        emit AddRemoveWhitelist(user_address, packageID, add_remove);
    }


    // Return the whitelisted status of a user. If whitelist is not active for the package, returns always true.
    function isUserWhitelisted(uint16 packageID, address user_address) public view returns (bool is_whitelisted) {
        if (package_buy_unlock_conditions[packageID].whitelist_enabled) {
            is_whitelisted = package_buy_unlock_conditions[packageID].whitelist[user_address];
        } else {
            is_whitelisted = true;
        }
    }


    // Function to update the pancake router or the BUSD token if needed
    function updateDEX(address _BUSD_Token) public onlyPowermadeOwner {
        pancakeRouter = IPancakeRouterView(powermadeToken.pancakeRouter());
        wbnb_token = pancakeRouter.WETH();
        price_reference_token = _BUSD_Token;
    }

}