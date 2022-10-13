/**
 *Submitted for verification at BscScan.com on 2022-10-13
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

// Inferface for NFTS
interface NFT721 {
    // Get the balance
    function balanceOf(address tokenOwner) external view returns (uint balance);
}

// Interface for People NFT smart contract (for minting)
interface PeopleNFT {
    function mintRandomPeopleTo(address _to) external;
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
contract ThresholdPeopleMinter is ExternalEligibilityContract {

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
    uint public price_threshold = starting_price_th;            // The current price threshold (BUSD)
    uint public lev4_PWD_threshold = lev4_PWD_start_th;         // The current PWD threshold for LV4
    uint public lev5_PWD_threshold = lev5_PWD_start_th;         // The current PWD threshold for LV5
    uint public last_price;                                     // Last price of the PWD token (in BUSD)
    uint public last_update_checkpoint;                         // The last update timestamp
    address public price_reference_token;                       // The BUSD token
    address private wbnb_token;                                 // The WBNB token, used for internal calculation

    // Events
    event UpdatedEvent(bool indexed updated_price, bool indexed updated_thresholds, uint checkpoint_ts, uint price_th, uint lev4_PWD_th, uint lev5_PWD_th);
    event UserAddedToWhitelist(address indexed user_address);

    // NFT Minter variables
    NFT721 public NFTpass;                                      // The NFT pass contract
    PeopleNFT public peopleNFTsc;                               // The People NFT smart contract 
    uint public exclusive_mint_deadline_timestamp;              // Expiration of the exclusive mint possibility for NFT pass holders
    uint8 public max_mintable_nopass;                           // Max number of mintable NFTs for users not holding the NFT pass
    uint8 public max_mintable_withpass;                         // Max number of mintable NFTs for users holding the NFT pass 
    bool public only_whitelisted_mode;                          // True if this smart contract is configured for whitelisted mode (only whitelisted addresses can mint)
    address public whitelist_manager;                           // Other Wallet that can add users to the whitelist (Powermade owner always can do it) 
    mapping(address => bool) public whitelist;                  // Whitelist used only when minter is deployed in whitelisted mode

    
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
    constructor(
        address _powermadeAddress, 
        address _powermadeToken, 
        address _BUSD_Token, 
        address _NFTpass, 
        uint _exclusive_mint_deadline_timestamp, 
        uint8 _max_mintable_nopass,
        uint8 _max_mintable_withpass,
        address _peopleNFTsc,
        bool _only_whitelisted_mode) 
    public {
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
        // NFT minter settings
        NFTpass = NFT721(_NFTpass);
        exclusive_mint_deadline_timestamp = _exclusive_mint_deadline_timestamp;
        max_mintable_nopass = _max_mintable_nopass;
        max_mintable_withpass = _max_mintable_withpass;
        only_whitelisted_mode = _only_whitelisted_mode;
        peopleNFTsc = PeopleNFT(_peopleNFTsc);
    }


    // Function used to specify an external wallet that can call the whitelisting function (it can be also a Smart Contract)
    function changeWhitelistManager(address _whitelist_manager) external onlyPowermadeOwner {
        require(only_whitelisted_mode, "Whitelist not enabled for this minter");
        whitelist_manager = _whitelist_manager;
    }


    // Function used to add a user address to the whitelist. It can be only added, not removed
    function addToWhitelist(address user_address) external {
        require(only_whitelisted_mode, "Whitelist not enabled for this minter");
        require(msg.sender == Powermade(powermadeContract).ownerWallet() || msg.sender == whitelist_manager, "Denied");     // Powermade owner or whitelist manager allowed
        whitelist[user_address] = true;
        emit UserAddedToWhitelist(user_address);
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
    function isEligibleExtW(address user_address, address, uint16, uint level, uint8 sourceID) public view returns (bool is_eligible) {
        if (sourceID == 1) {        // Case Package Buy
            // Check whitelist (if enabled)
            if (only_whitelisted_mode && !whitelist[user_address]) {
                return false;
            }
            bool isNFTpass = address(NFTpass) == address(0) ? false : NFTpass.balanceOf(user_address) >= 1;
            // Exclusive mint period
            if (block.timestamp <= exclusive_mint_deadline_timestamp && !isNFTpass) {
                return false;
            }
            if (!isNFTpass && level < max_mintable_nopass) {
                return true;
            } else if (isNFTpass && level < max_mintable_withpass) {
                return true;
            } else {
                return false;
            }
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
    function isEligibleExt(address user_address, address, uint16, uint level, uint8 sourceID) external onlyPowermadeContract returns (bool is_eligible) {
        // Call the update function
        updatePriceThresholds(false);
        // NFT minting
        if (sourceID == 1) {        // Case Package Buy
            require(!only_whitelisted_mode || whitelist[user_address], "Not whitelisted");      // Check whitelist (if enabled)
            bool isNFTpass = address(NFTpass) == address(0) ? false : NFTpass.balanceOf(user_address) >= 1;
            // Exclusive mint period
            if (block.timestamp <= exclusive_mint_deadline_timestamp) {
                if (address(NFTpass) == address(0)) {
                    revert("Cannot Mint Yet");
                }
                require(isNFTpass, "No NFT Pass");
            }
            // Max mintable quantity (level is also the n_bought in this case, excluding the current purchase)
            if (!isNFTpass) {
                if (max_mintable_nopass == 0) {
                    revert("Mint Disabled");
                }
                require(level < max_mintable_nopass, "Max Mintable quantity reached");
            } else {
                if (max_mintable_withpass == 0) {
                    revert("Mint Disabled");
                }
                require(level < max_mintable_withpass, "Max Mintable quantity reached");
            }
            // Minting part (requires minter role configured in the People NFT smart contract)
            peopleNFTsc.mintRandomPeopleTo(user_address);
            return true;
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


    // Function to update the pancake router or the BUSD token if needed
    function updateDEX(address _BUSD_Token) public onlyPowermadeOwner {
        pancakeRouter = IPancakeRouterView(powermadeToken.pancakeRouter());
        wbnb_token = pancakeRouter.WETH();
        price_reference_token = _BUSD_Token;
    }

}