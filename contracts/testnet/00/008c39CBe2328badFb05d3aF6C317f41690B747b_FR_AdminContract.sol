// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "FR_IDataContract.sol";
contract FR_AdminContract{
    FR_IDataContract fr_idataContract;
    event AddProperty(uint256 indexed _event_id, string _call_ref_id, uint256 indexed _property_id);

    function setFRIDataContract(address dataContract) public{
        fr_idataContract= FR_IDataContract(dataContract);
    }
    function setAddProperty(
        string memory _call_ref_id,
        string memory _property_name,
        uint256 _listing_date,
        uint256 _number_of_shares,
        uint256 _limit_per_share,
        uint256 _property_price,
        uint256 _price_per_share,
        uint256 _property_discount
    ) public {
        fr_idataContract.checkRole(msg.sender, keccak256('ADMIN_ROLE'));
        uint256 _event_id = fr_idataContract.generateEventId();
        uint256 _propertyId = fr_idataContract.generatePropertyId();
        
        fr_idataContract.addProperty(
            _propertyId,
            _property_name,
            _listing_date,
            _number_of_shares,
            _limit_per_share,
            _property_price,
            _price_per_share,
            _property_discount
        );

        emit AddProperty(_event_id, _call_ref_id, _propertyId);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "FR_Library.sol";

// Define the interface for the FR_DataContract smart contract
interface FR_IDataContract {
    function checkRole(address account, bytes32 role) external view ;
    // Define the function to generate an event ID
    function generateEventId() external returns (uint256);
    
    // Define the function to generate a property ID
    function generatePropertyId() external returns (uint256);
    
    // Define the function to get the details of a property
    function getProperty(uint256 _propertyID) external view returns (FR_Library.Property_Struct memory);
    
    // Define the function to get the price details of a property
    function getPropertyPrice(uint256 _propertyID) external view returns (FR_Library.Property_Price_Struct memory);
    
    // Define the function to get the status of a property
    function getPropertyStatus(uint256 _propertyID) external view returns (FR_Library.Property_Status_Struct memory);
    
    // Define the function to add a new property
    function addProperty(
        uint256 _property_id,
        string calldata _property_name,
        uint256 _listing_date,
        uint256 _number_of_shares,
        uint256 _limit_per_share,
        uint256 _property_price,
        uint256 _price_per_share,
        uint256 _property_discount
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
library FR_Library{
    struct Property_Struct{
        string propertyName;
        uint256 listingDate;
        uint256 totalShares;
        uint256 soldShares;
        uint256 limitPerShare;
        address nftToken;
        uint256 lastUpdated;
    }
    struct Property_Price_Struct{
        uint256 propertyPrice;
        uint256 pricePerShare;
        uint256 propertyDiscount;
        uint256 lastUpdated;
    }
    struct Property_Status_Struct{
        string saleStatus;
        string SPVStatus;
        string NFTStatus;
        string resaleStatus;
        uint256 lastUpdated;
    }
}