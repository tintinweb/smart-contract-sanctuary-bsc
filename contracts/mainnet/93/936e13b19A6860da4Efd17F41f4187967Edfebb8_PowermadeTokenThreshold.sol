/**
 *Submitted for verification at BscScan.com on 2022-06-03
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
contract PowermadeTokenThreshold is ExternalEligibilityContract {

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

    // Storage variables
    mapping (uint16 => uint) private package_buy_threshold_amount_PWD;      // Threshold for the package BUY (configurable)
    uint public price_threshold = starting_price_th;            // The current price threshold (BUSD)
    uint public lev4_PWD_threshold = lev4_PWD_start_th;         // The current PWD threshold for LV4
    uint public lev5_PWD_threshold = lev5_PWD_start_th;         // The current PWD threshold for LV5
    uint public last_price;                                     // Last price of the PWD token (in BUSD)
    uint public last_update_checkpoint;                         // The last update timestamp
    address public price_reference_token;                       // The BUSD token
    address private wbnb_token;                                 // The WBNB token, used for internal calculation

    // Events
    event UpdatedEvent(bool indexed updated_price, bool indexed updated_thresholds, uint checkpoint_ts, uint price_th, uint lev4_PWD_th, uint lev5_PWD_th);


    
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


    // Implementation of the ExternalEligibilityContract interface (only used parameters). View function.
    function isEligibleExtW(address user_address, address, uint16 packageID, uint level, uint8 sourceID) public view returns (bool is_eligible) {
        if (sourceID == 1) {        // Case Package Buy
            return (powermadeToken.balanceOf(user_address) >= package_buy_threshold_amount_PWD[packageID]);
        } else if (sourceID == 2) {     // Case sponsor commission (direct)
            return true;
        } else if (sourceID == 3) {     // Case level commission. param1 is the distributed level
            if (level == 4) {
                 return (powermadeToken.balanceOf(user_address) >= lev4_PWD_threshold);
            } else if (level == 5) {
                return (powermadeToken.balanceOf(user_address) >= lev5_PWD_threshold);
            } else {
                return true;
            }
        } else {
            return true;
        }
    }

    // Implementation of the ExternalEligibilityContract interface (only used parameters). Call function (it can update storage)
    function isEligibleExt(address user_address, address, uint16 packageID, uint level, uint8 sourceID) external onlyPowermadeContract returns (bool is_eligible) {
        // Call the update function
        updatePriceThresholds(false);
        // Return the eligibility
        return isEligibleExtW(user_address, address(0), packageID, level, sourceID);
    }


    // Set the threshold in token for the Buy Package operation (when configured)
    function setPackagePWDthreshold(uint16 packageID, uint threshold_pwd_wei) external onlyPowermadeOwner {
        (uint price, , , , , , , , , , ) = powermadeContract.getPackageInfo(packageID, 0);
        require(price > 0, "Package does not exist");
        require(packageID > 1, "Invalid packageID");
        package_buy_threshold_amount_PWD[packageID] = threshold_pwd_wei;
    }

    // Get the current PWD threshold used for the Packages
    function getPackagePWDthreshold(uint16 packageID) external view returns (uint) {
        return package_buy_threshold_amount_PWD[packageID];
    }

    // Function to update the pancake router or the BUSD token if needed
    function updateDEX(address _BUSD_Token) public onlyPowermadeOwner {
        pancakeRouter = IPancakeRouterView(powermadeToken.pancakeRouter());
        wbnb_token = pancakeRouter.WETH();
        price_reference_token = _BUSD_Token;
    }

}