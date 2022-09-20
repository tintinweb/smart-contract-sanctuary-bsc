/**
 *Submitted for verification at BscScan.com on 2022-09-19
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

pragma solidity ^0.8.13;

// Interface of a token BEP20 - ERC20 - TRC20 - .... All functions of the standard interface are declared, even if not used
interface TOKEN20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address tokenOwner) external view returns (uint balance);
    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function transfer(address to, uint tokens) external returns (bool success);
    function approve(address spender, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

// Inferface for generic token (fungible) or NFT balance + rarity check. In the case of rarity check the NFT must implement ERC721Enumerable and the custom getRarity()
interface ThresholdTokenOrNFT {
    // Get the balance
    function balanceOf(address tokenOwner) external view returns (uint balance);
    // Get the rarity (ONLY COMPATIBLE NFTS), the feature must be enabled
    function getRarity(uint256 tokenId) external view returns (uint8 rarity);
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenID);
}

// Interface of the PancakeSwap Router
// Reduced Interface only for the needed functions
interface IPancakeRouter {
    function WETH() external pure returns (address);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
}

// Interface to access Powermade contract data
interface Powermade {
    // get the owner 
    function ownerWallet() external view returns (address owner);
    // Get the token used by the Affiliation system (BUSD)
    function token_addr() external view returns (address token_address);
    // userIDaddress getter function
    function userIDaddress(uint userID) external view returns (address userAddr);
    // userInfos getter function (automatically generated because userInfos mapping is public). The getter can only contain standard types, not arrays or other mappings.
    function userInfos(address userAddr) external view returns (uint id, uint referrerID, uint virtualID, uint32 round_robin_next_index, bool banned, uint totalEarned);
    // Get the package Info (and package info associated to a userID)
    function getPackageInfo(uint16 packageID, uint userID) external view returns (uint price, uint duration, bool enabled, bool rebuy_enabled, bool rebuy_before_exp, uint16[] memory prerequisites, uint16[] memory percentages, bool prereq_not_exp, uint totalEarnedPack, uint purchasesCount, uint last_pid);
    // businessEnabled getter function
    function businessEnabled() external view returns (bool enabled);
    // Function used to buy packages (or register users) from external allowed contracts 
    function BuyPackageExt(address userAddr, uint sponsorID, uint16 packageID, bool pay_commissions) external;
}

// Interface of the Powermade Token, that implements also a standard BEP20 interface. Only needed functions are included
interface PowermadeToken is TOKEN20 {
    // Get the pancake router used by the token
    function pancakeRouter() external view returns (address);
}

// Interface of the Integration Vault
interface PowermadeIntegrationVault {
    function withdrawToken(address token, uint amount, address destination) external;
}


contract DiscountWrapperStandalone {

    uint constant private MAX_UINT = 2**256 - 1;

    Powermade public powermadeContract;                         // The PowermadeAffiliation contract
    PowermadeToken public PWDtokenContract;                     // PWD token smart contract
    PowermadeIntegrationVault public powermadeVault;            // The integration vault
    address public affiliation_token_used;                      // A mirror of the token used by the Affiliation Smart Contract. If changed must be reloaded/reapproved with the reApproveToken()
    address public constant address_zero = address(0);          // The address(0)
    bool public def_use_direct_pool;                            // Default value. Set if direct pool must be used for conversion. Price reference for discount calculation is always with the WBNB path
    uint16 public def_percent_to_convert;                       // Default value. The percentage of the PWD deposit to be automatically converted into BUSD (0 - 1000)
    uint16 public def_slippage_tax_percentage;                  // Default value. The percentage used to increment the PWD amount to take into account the Exchange slippage when selling automatically (0 - 30 perthousand)

    struct Discounts {
        address[] token_addresses;      // token or NFT address
        uint[] thresholds;              // Threshold amounts (Wei unit or NFT amount)
        uint8[] rarities;               // Minumum rarity level (included). If 0 it means all rarities and the rarity won't be checked
        uint16[] percentages;           // associated percentages (per-thousands)
        uint8[] levels;                 // Associated levels (only display use)
    }

    struct QuantityDiscount {
        uint16 percentage;              // If percentage is 0, the discount is disabled
        address token_address;          // if is address(0) the number of already bought packages will be used
        uint threshold;                 // Threshold in units or Wei
    }

    struct ConversionSettings {
        // Per-package values (override default when set)
        bool override_default;
        bool use_direct_pool;
        uint16 percent_to_convert;
        uint16 slippage_tax_percentage;
    }

    mapping(uint16 => Discounts) private packageDiscounts;                       // Associate discounts to each packageID. Can be used to read the settings
    mapping(uint16 => QuantityDiscount) private packageQuantityDiscounts;        // Associate quantity discounts to each packageID. Can be used to read the settings
    mapping(uint16 => ConversionSettings) public packageConversionSettings;      // Conversion settings for each package

    // Events
    event ChangedFeatureParameterEv(string indexed tag);    // Indexed strings are saved as keccak256(string)
    event AutoConvertedPWDtoAffiliationNative(uint amount, bool direct_pool, uint finalBalancePWD, uint finalBalanceToken);
    event BuyPackageWithPWDEv(address indexed user_address, uint16 indexed packageID, uint package_price_native, int8 index, uint16[] applied_percentages, uint package_price_native_discounted, uint pwd_amount_discounted, uint pwd_required, uint remainingPWD, uint native_needed);

    // Modifier to be used with functions that can be called only by The Owner of the Powermade Main contract
    modifier onlyPowermadeOwner()
    {
        require(msg.sender == powermadeContract.ownerWallet(), "Denied");
        _;
    }

    // Modifier to be used with functions that can be called only by The PowermadeAffiliation contract
    modifier onlyPowermadeContract()
    {
        require(msg.sender == address(powermadeContract), "Denied");
        _;
    }

    // Constructor called when deploying
    constructor(address _powermadeAddress, address _PWD_token_address, address _powermadeVault_address) {
        powermadeContract = Powermade(_powermadeAddress);
        PWDtokenContract = PowermadeToken(_PWD_token_address);
        powermadeVault = PowermadeIntegrationVault(_powermadeVault_address);
        // Approve BUSD (infinite) for the Powermade main contract
        affiliation_token_used = powermadeContract.token_addr();
        bool outcome = TOKEN20(affiliation_token_used).approve(_powermadeAddress, MAX_UINT);
        require(outcome, "Something went wrong");
    }



    // Get the current discount percentages (per-thousands). If index is -1 no level is applicable (and level discount must be 0)
    function getCurrentDiscount(address user_address, uint16 packageID) public view returns (uint8 level, int8 index, uint16 quantity_percentage, uint16 level_percentage, uint16 total_percentage) {
        (uint userID, , , , , ) = powermadeContract.userInfos(user_address);    // Get userID. If 0, it's a new user (not in PowermadeAffiliation, possible new registration)
        if (userID == 0) {
            packageID = 0;      // Use the data stored into packageID=0 (used for new registrations)
        }
        // Evaluate quantity discount
        if (packageQuantityDiscounts[packageID].percentage > 0) {
            if (packageQuantityDiscounts[packageID].token_address == address(0) && userID > 0) {
                // Use package purchases (not used if the user is not in the affiliation smart contract)
                (, , , , , , , , , uint purchasesCount, ) = powermadeContract.getPackageInfo(packageID, userID);
                if (purchasesCount >= packageQuantityDiscounts[packageID].threshold) {
                    quantity_percentage = packageQuantityDiscounts[packageID].percentage;
                } else {
                    quantity_percentage = 0;
                }
            } else if (packageQuantityDiscounts[packageID].token_address != address(0)) {
                // Use token address
                if (ThresholdTokenOrNFT(packageQuantityDiscounts[packageID].token_address).balanceOf(user_address) >= packageQuantityDiscounts[packageID].threshold) {
                    quantity_percentage = packageQuantityDiscounts[packageID].percentage;
                } else {
                    quantity_percentage = 0;
                }
            }
        } else {
            quantity_percentage = 0;
        }
        // Evaluate level discount
        level_percentage = 0;
        index = -1;     // Default no level (level is 0 and percentage associated is 0)
        for (int i = int(packageDiscounts[packageID].thresholds.length) - 1; i >= 0; i--) {
            ThresholdTokenOrNFT target_token = ThresholdTokenOrNFT(packageDiscounts[packageID].token_addresses[uint(i)]);
            // Rarity check (custom NFTs)
            if (packageDiscounts[packageID].rarities[uint(i)] > 0) {
                // Rarity NFT mode
                uint rarity_counter = 0;
                for (uint j = 0; j < target_token.balanceOf(user_address); j++) {
                    uint tokenID = target_token.tokenOfOwnerByIndex(user_address,j);
                    if (target_token.getRarity(tokenID) >= packageDiscounts[packageID].rarities[uint(i)]) {
                        rarity_counter++;
                    }
                }
                if (rarity_counter >= packageDiscounts[packageID].thresholds[uint(i)]) {
                    level_percentage = packageDiscounts[packageID].percentages[uint(i)];
                    level = packageDiscounts[packageID].levels[uint(i)];
                    index = int8(i);
                    break;      // Found the discount
                }
            } else {
                // No rarity mode OR general fungible token
                if (target_token.balanceOf(user_address) >= packageDiscounts[packageID].thresholds[uint(i)]) {
                    level_percentage = packageDiscounts[packageID].percentages[uint(i)];
                    level = packageDiscounts[packageID].levels[uint(i)];
                    index = int8(i);
                    break;      // Found the discount
                }
            }
        }
        // Evaluate total discount percentage (perthousand)
        // y = x*(1-p1/1000)*(1-p2/1000)=x*(1-p1/1000-p2/1000+p1/100*p2/1000)=x*(1-(p1+p2-p1*p2/1000)/1000) = x*(1-pt/1000)  where  pt = p1+p2-(p1*p2/1000)
        total_percentage = quantity_percentage + level_percentage - uint16(uint(quantity_percentage)*uint(level_percentage)/1000);
        // Coerce to 1000, that is the max percentage (to be sure)
        total_percentage = total_percentage > 1000 ? 1000 : total_percentage;
    }


    // Get configured discounts
    // packageID = 0 is the discount associated to the first registration (new user), the packageID = 1 is the discount associated to the package for the renewal 
    function getConfiguredDiscounts(uint16 packageID) public view returns (address[] memory token_addresses, uint[] memory thresholds, uint8[] memory rarities, uint16[] memory percentages, uint8[] memory levels, QuantityDiscount memory quantity_discount_info) {
        token_addresses = packageDiscounts[packageID].token_addresses;
        thresholds = packageDiscounts[packageID].thresholds;
        rarities = packageDiscounts[packageID].rarities;
        percentages = packageDiscounts[packageID].percentages;
        levels = packageDiscounts[packageID].levels;
        quantity_discount_info = packageQuantityDiscounts[packageID];
    }


    // Get the original price in native token (BUSD) and PWD, and the discounted price in native token (BUSD) and PWD. The last one must be used for the pay with PWD feature
    function getDiscountedAmounts(address user_address, uint16 packageID) public view returns (uint sc_native_amount, uint pwd_not_discounted, uint native_discounted, uint pwd_amount_discounted) {
        (, , , , uint16 total_percentage) = getCurrentDiscount(user_address, packageID);
        return getDiscountedAmountsFromPercentage(packageID, total_percentage);
    }


    // Function to get the discounted amount passing an arbitrary percentage (per-thousand)
    function getDiscountedAmountsFromPercentage(uint16 packageID, uint16 total_percentage) public view returns (uint sc_native_amount, uint pwd_not_discounted, uint native_discounted, uint pwd_amount_discounted) {
        (sc_native_amount, , , , , , , , , , ) = powermadeContract.getPackageInfo(packageID, 0);
        native_discounted = sc_native_amount - sc_native_amount * total_percentage / 1000;     // y = x*(1-pt/1000) = x - x*pt/1000
        uint conv_rate = previewConversionReceivedAmount(1,false,false,false);
        pwd_not_discounted = sc_native_amount * conv_rate / 1e18;
        pwd_amount_discounted = native_discounted * conv_rate / 1e18;
    }


    // Get current applied discount, discounted prices and other info. Useful for the frontend 
    // Can be used the userID or the user_address. For new users (registration) only user_address is a valid option
    // applied_percentages = [quantity_percentage, level_percentage, total_percentage]  --  Use applied_percentages[2] for the discounted percentage applied
    // prices = [sc_native_amount, pwd_not_discounted, native_discounted, pwd_amount_discounted]
    // sc_native_amount and pwd_not_discounted for convenience (frontend purpose)  --  use pwd_amount_discounted for the price and pwd_amount_discounted*1.1 for the approval
    // info_codes not used now. But the rule is set for discont types and IDs.
    function getDiscountsInfos(uint userID, address user_address, uint16 packageID) public view returns (int8 index, uint8 level, uint16[] memory applied_percentages, uint[] memory prices, uint8[] memory info_codes) {
        if (userID > 0) {
            user_address = powermadeContract.userIDaddress(userID);
        }
        require(user_address != address(0), "Invalid UserID or user_address");
        applied_percentages = new uint16[](3);
        prices = new uint[](4);
        info_codes = new uint8[](4);
        (level, index, applied_percentages[0], applied_percentages[1], applied_percentages[2]) = getCurrentDiscount(user_address, packageID);
        (prices[0], prices[1], prices[2], prices[3]) = getDiscountedAmounts(user_address, packageID);
        info_codes[1] = 0;      // applied_discountID - Not used now
        info_codes[0] = 0;      // discount_type - Local discount (1 is global, 2 is special, future use). Global has reserved IDs 1 to 100, special 101 to infinite
        if (info_codes[1] > 0 && info_codes[1] < 101) { 
            info_codes[0] = 1;
        } else if (info_codes[1] > 0 && info_codes[1] >= 101) {
            info_codes[0] = 2;
        }
        info_codes[2] = 0;      // set_discountID - Not used now
        info_codes[3] = 0;      // fallbackID - Not used now
    }



    // Function used to preview the received amount before a conversion. It returns the received amount in Wei
    // Can be used to obtain the exchange rate (indicative) passing amount = 1 and amount_is_cents = false 
    // Default is the number of PWD you recive for 1 native token (BUSD), but can be used to calculate the opposite (value of 1 PWD expressed in BUSD)
    function previewConversionReceivedAmount(uint amount, bool direct_pool, bool amount_is_cents, bool PWD_to_native) public view returns (uint received_amount) {
        if (!amount_is_cents) {
            amount = amount * 1e18;       // coin_unit = 1e18
        }
        IPancakeRouter pancakeRouter = IPancakeRouter(PWDtokenContract.pancakeRouter());
        address[] memory path;
        if (direct_pool) {
            path = new address[](2);
            path[0] = PWD_to_native ? address(PWDtokenContract) : affiliation_token_used;
            path[1] = PWD_to_native ? affiliation_token_used : address(PWDtokenContract);
            received_amount = pancakeRouter.getAmountsOut(amount, path)[1];
        } else {
            path = new address[](3);
            path[0] = PWD_to_native ? address(PWDtokenContract) : affiliation_token_used;
            path[1] = pancakeRouter.WETH();
            path[2] = PWD_to_native ? affiliation_token_used : address(PWDtokenContract);
            received_amount = pancakeRouter.getAmountsOut(amount, path)[2];
        }    
    }



    // Function to be called to buy a package (excluded packageID 1) using the PWD Tokens with a discount
    // The amount of PWD to be automatically converted in BUSD (Powermade Affiliation native token) can be configured
    // The extra BUSD needed amount will be withdrawn from the Powermade Integration Vault (the tx will fail if the amount of BUSD in the vault is not enough)
    // Remainings are all sent to the Vault, nothing will remain in the contract.
    function BuyPackagePWD(uint sponsorID, uint16 packageID) external {
        // Requires
        require(msg.sender == tx.origin, "OriginE");
        require(powermadeContract.businessEnabled(), "GlobalEN");   // The business must be enabled
        // First determine the amount (PWD discounted)
        uint16[] memory applied_percentages = new uint16[](3);
        int8 index;
        (, index, applied_percentages[0], applied_percentages[1], applied_percentages[2]) = getCurrentDiscount(msg.sender, packageID);
        (uint package_price_native, , uint package_price_native_discounted, uint pwd_amount_discounted) = getDiscountedAmountsFromPercentage(packageID, applied_percentages[2]);    // Calculate with total_percentage = applied_percentages[2]
        // Add the Slippage tax
        // pwd_required = pwd_amount_discounted + pwd_amount_discounted * slippage_tax_percentage / 1000
        uint pwd_required = pwd_amount_discounted + pwd_amount_discounted * (packageConversionSettings[packageID].override_default ? packageConversionSettings[packageID].slippage_tax_percentage : def_slippage_tax_percentage) / 1000;
        // Request the deposit (transferFrom) for PWD tokens (IMPORTANT: Tax and other restrictions must be disabled on this contract)
        _depositTokenContract(address(PWDtokenContract), pwd_required);
        // Convert the specified part to BUSD automatically through the defined route
        uint availableNative = 0; 
        uint remainingPWD = pwd_required;
        if ((packageConversionSettings[packageID].override_default ? packageConversionSettings[packageID].percent_to_convert : def_percent_to_convert) > 0) {       // percent_to_convert > 0
            // amount_to_convert = pwd_required * percent_to_convert / 1000
            uint amount_to_convert = pwd_required * (packageConversionSettings[packageID].override_default ? packageConversionSettings[packageID].percent_to_convert : def_percent_to_convert) / 1000;
            bool use_direct_pool = (packageConversionSettings[packageID].override_default ? packageConversionSettings[packageID].use_direct_pool : def_use_direct_pool);
            (availableNative, remainingPWD) = _convertPWDtoTokenUsed(affiliation_token_used, amount_to_convert, use_direct_pool);
        }
        // Send the remaining PWD (if any) to the Vault
        if (remainingPWD > 0) {
            TOKEN20(address(PWDtokenContract)).transfer(address(powermadeVault), remainingPWD);
        }
        // Request the missing BUSD amount from the Vault
        uint native_needed = availableNative >= package_price_native ? 0 : package_price_native - availableNative;
        if (native_needed > 0) {
            powermadeVault.withdrawToken(affiliation_token_used, native_needed, address(this));
        }
        // Call the buyPackage function (BUSD Already approved in the constructor for infinite amount)
        powermadeContract.BuyPackageExt(msg.sender, sponsorID, packageID, true);
        // Transfer to Vault any remaining BUSD (should be 0)
        uint remainingNative = TOKEN20(affiliation_token_used).balanceOf(address(this));
        if (remainingNative > 0) {
            TOKEN20(affiliation_token_used).transfer(address(powermadeVault), remainingNative);
        }
        // Emit Event
        emit BuyPackageWithPWDEv(msg.sender, packageID, package_price_native, index, applied_percentages, package_price_native_discounted, pwd_amount_discounted, pwd_required, remainingPWD, native_needed);
    }


    // Utility function to send a token to the smart contract balance
    // The transaction must be approved externally (in JS frontend) with 
    // token_addr.approve(smart_contract, amount)
    function _depositTokenContract(address token_address, uint amount) private {
        require(amount > 0, "You are not sending anything!");
        bool success = TOKEN20(token_address).transferFrom(msg.sender, address(this), amount);
        require(success, "Token transfer to contract failed. Check allowance!");
    }


    // Internal function used for the conversion
    function _convertPWDtoTokenUsed(address token_used, uint amount, bool direct_pool) private returns(uint finalBalanceToken, uint finalBalancePWD) {
        IPancakeRouter pancakeRouter = IPancakeRouter(PWDtokenContract.pancakeRouter());
        address[] memory path;
        if (direct_pool) {
            path = new address[](2);
            path[0] = address(PWDtokenContract);
            path[1] = token_used;
        } else {
            path = new address[](3);
            path[0] = address(PWDtokenContract);
            path[1] = pancakeRouter.WETH();
            path[2] = token_used;
        }
        PWDtokenContract.approve(address(pancakeRouter), amount);
        // make the swap
        pancakeRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amount,
            0,      // Accept any amount of converted Token
            path,
            address(this),      // Send to the contract
            block.timestamp
        );
        finalBalanceToken = TOKEN20(token_used).balanceOf(address(this));
        finalBalancePWD = PWDtokenContract.balanceOf(address(this));
        emit AutoConvertedPWDtoAffiliationNative(amount, direct_pool, finalBalancePWD, finalBalanceToken);
    }



    // Function used to set the (local) discounts associated to a packageID
    // Important: same level number should (must) have the same percentage
    // packageID = 0 is the discount associated to the first registration (new user), the packageID = 1 is the discount associated to the package for the renewal 
    function setDiscounts(uint16 packageID, address[] memory token_addresses, uint[] memory thresholds, uint8[] memory rarities, uint16[] memory percentages, uint8[] memory levels, bool intelligentUnit) external onlyPowermadeOwner {
        // Basic checks
        require(token_addresses.length == thresholds.length && token_addresses.length == rarities.length && token_addresses.length == percentages.length && token_addresses.length == levels.length, "Size Err");
        for (uint8 i = 0; i < token_addresses.length; i++) {
            require(token_addresses[i] != address(0) && isContract(token_addresses[i]), "Val Err");
            require(percentages[i] <= 1000, "Val Err");
            require(levels[i] > 0, "Val Err");
            if (intelligentUnit) {
                if (thresholds[i] > 100 && thresholds[i] < 1e6) {
                    // Probably not NFT and value espressed in human unit 
                    thresholds[i] = thresholds[i] * 1e18;
                }
            }
        }
        // Save data
        packageDiscounts[packageID].token_addresses = token_addresses;
        packageDiscounts[packageID].thresholds = thresholds;
        packageDiscounts[packageID].rarities = rarities;
        packageDiscounts[packageID].percentages = percentages;
        packageDiscounts[packageID].levels = levels;
        emit ChangedFeatureParameterEv("setDiscounts");
    }


    // Configure the Quantity discount (applied before the other discounts)
    function setQuantityDiscount(uint16 packageID, uint16 percentage, address token_address, uint threshold, bool intelligentUnit) external onlyPowermadeOwner {
        require(percentage <= 1000, "Val Err");
        if (token_address != address(0)) {
            require(isContract(token_address), "Val Err");
        }
        if (intelligentUnit) {
            if (threshold > 100 && threshold < 1e6) {
                // Probably not NFT and value espressed in human unit 
                threshold = threshold * 1e18;
            }
        }
        packageQuantityDiscounts[packageID].percentage = percentage;
        packageQuantityDiscounts[packageID].token_address = token_address;
        packageQuantityDiscounts[packageID].threshold = threshold;
        emit ChangedFeatureParameterEv("setQuantityDiscount");
    }


    // Configure the Auto conversion feature to automatically convert part (or all) the PWD into the native token (BUSD) used by Powermade Affiliation SC
    // Set also (change) the address of the Powermade Vault (if need to upgrade). This contract must be enabled in the Vault.
    // This function will change the default parameters that can be overriden for each package
    function setDefaultConversionSettings(uint16 _def_percent_to_convert, uint16 _def_slippage_tax_percentage, bool _def_use_direct_pool, address _powermadeVault_address) external onlyPowermadeOwner {
        require(_def_percent_to_convert <= 1000, "Val Err");
        require(_def_slippage_tax_percentage <= 30, "Val Err");     // Max slippage tax can be 3%
        def_percent_to_convert = _def_percent_to_convert;
        def_slippage_tax_percentage = _def_slippage_tax_percentage;
        def_use_direct_pool = _def_use_direct_pool;
        if (_powermadeVault_address != address(0)) {
            require(isContract(_powermadeVault_address), "Val Err");
            powermadeVault = PowermadeIntegrationVault(_powermadeVault_address);
        }
        emit ChangedFeatureParameterEv("setDefaultConversionSettings");
    }


    // Configure the overrides for the single packageIDs. In this case there is no packageID=0 setting. The packageID=1 setting will be used both for new registrations and re-purchases (if enabled, when paying with PWD). 
    function setPackageIDConversionSettings(uint16 packageID, bool _override_default, uint16 _percent_to_convert, uint16 _slippage_tax_percentage, bool _use_direct_pool) external onlyPowermadeOwner {
        require(_percent_to_convert <= 1000, "Val Err");
        require(_slippage_tax_percentage <= 30, "Val Err");     // Max slippage tax can be 3%
        packageConversionSettings[packageID].override_default = _override_default;
        packageConversionSettings[packageID].percent_to_convert = _percent_to_convert;
        packageConversionSettings[packageID].slippage_tax_percentage = _slippage_tax_percentage;
        packageConversionSettings[packageID].use_direct_pool = _use_direct_pool;
        emit ChangedFeatureParameterEv("setPackageIDConversionSettings");
    }    


    // The Powermade owner must call this function if the token used in the Powermade contract has been changed
    function reApproveToken() external onlyPowermadeOwner {
        affiliation_token_used = powermadeContract.token_addr();
        // Approve (infinite) for the Powermade main contract
        bool outcome = TOKEN20(affiliation_token_used).approve(address(powermadeContract), MAX_UINT);
        require(outcome, "Something went wrong");
        emit ChangedFeatureParameterEv("reApproveToken");
    }


    // Extract tokens from the contract (sent to the contract for mistake. There should not be tokens stored into this contract!). Callable only by the Powermade owner
    function retriveTokensContract(address token, uint amount, address destination) external onlyPowermadeOwner {
        TOKEN20(token).transfer(destination, amount);      // Do the token transfer. The source is the contract itself
    }

    // Check if an address is a Smart Contract
    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }


}