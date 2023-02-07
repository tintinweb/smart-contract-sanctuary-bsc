// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./interfaces/IHotelPlanFactory.sol";
import "./interfaces/IReservationFactory.sol";

contract Statistics {

    IHotelPlanFactory public immutable HOTEL_PLAN_FACTORY;
    IReservationFactory public immutable RESERVATION_FACTORY;

    mapping(address => UserInfo) public userTotalInfo;
    mapping(address => mapping(address => UserInfo)) public userPerHotelInfo;
    mapping(address => HotelInfo) public hotelTotalInfo;
    mapping(address => HotelAdminInfo) public hotelAdminTotalInfo;

    mapping(address => mapping(uint256 => address)) public hotelOfAdminInOrder;

    struct UserInfo {
        uint256 firstMintTimestamp;
        uint256 firstReservationCreatedTimestamp;
        uint256 minted;
        uint256 boughtSum;
        uint256 reservationItemsRegistered;
        uint256 reservationItemsSuccess;
        uint256 reservationItemsFailure;
    }

    struct HotelInfo {
        uint256 internalIDsCreated;
        uint256 minted;
        uint256 boughtSum;
        uint256 reservationItemsRegistered;
        uint256 reservationItemsSuccess;
        uint256 reservationItemsFailure;
    }

    struct HotelAdminInfo {
        uint256 firstHotelCreatedTimestamp;
        uint256 hotelsCreated;
        uint256 hotelsTerminated;
        uint256 internalIDsCreated;
        uint256 minted;
        uint256 boughtSum;
        uint256 reservationItemsRegistered;
        uint256 reservationItemsSuccess;
        uint256 reservationItemsFailure;
    }

    modifier onlyHotelPlan {
        require(HOTEL_PLAN_FACTORY.isDeployedByFactory(msg.sender), "Not a hotel plan");
        _;
    }

    modifier onlyReservation {
        require(RESERVATION_FACTORY.isDeployedByFactory(msg.sender), "Not a reservation");
        _;
    }

    constructor(IHotelPlanFactory _hotelPlanFactory, IReservationFactory _reservationFactory) {
        HOTEL_PLAN_FACTORY = _hotelPlanFactory;
        RESERVATION_FACTORY = _reservationFactory;
    }

    function handleCreateInternalID(address hotelAdmin) external onlyHotelPlan {
        if (hotelTotalInfo[msg.sender].internalIDsCreated == 0) {
            if (hotelAdminTotalInfo[hotelAdmin].hotelsCreated == 0) {
                hotelAdminTotalInfo[hotelAdmin].firstHotelCreatedTimestamp = block.timestamp;
            }
            hotelOfAdminInOrder[hotelAdmin][hotelAdminTotalInfo[hotelAdmin].hotelsCreated] = msg.sender;
            hotelAdminTotalInfo[hotelAdmin].hotelsCreated++;
        }
        hotelTotalInfo[msg.sender].internalIDsCreated++;
        hotelAdminTotalInfo[hotelAdmin].internalIDsCreated++;
    }

    function handleTerminateHotel(address hotelAdmin) external onlyHotelPlan {
        if (hotelTotalInfo[msg.sender].internalIDsCreated > 0) {
            hotelAdminTotalInfo[hotelAdmin].hotelsTerminated++;
        }
    }

    function handleMint(address user, address hotelAdmin, uint256 amount, uint256 sum) external onlyHotelPlan {
        if (userPerHotelInfo[user][msg.sender].minted == 0) {
            userPerHotelInfo[user][msg.sender].firstMintTimestamp = block.timestamp;
            if (userTotalInfo[user].minted == 0) {
                userTotalInfo[user].firstMintTimestamp = block.timestamp;
            }
        }
        userTotalInfo[user].minted += amount;
        userTotalInfo[user].boughtSum += sum;
        userPerHotelInfo[user][msg.sender].minted += amount;
        userPerHotelInfo[user][msg.sender].boughtSum += sum;
        hotelTotalInfo[msg.sender].minted += amount;
        hotelTotalInfo[msg.sender].boughtSum += sum;
        hotelAdminTotalInfo[hotelAdmin].minted += amount;
        hotelAdminTotalInfo[hotelAdmin].boughtSum += sum;
    }

    function handleCreateReservation(address hotelPlan, address user, address hotelAdmin, uint256 amount) external onlyReservation {
        if (userPerHotelInfo[user][hotelPlan].reservationItemsRegistered == 0) {
            userPerHotelInfo[user][hotelPlan].firstReservationCreatedTimestamp = block.timestamp;
            if (userTotalInfo[user].reservationItemsRegistered == 0) {
                userTotalInfo[user].firstReservationCreatedTimestamp = block.timestamp;
            }
        }
        userTotalInfo[user].reservationItemsRegistered += amount;
        userPerHotelInfo[user][hotelPlan].reservationItemsRegistered += amount;
        hotelTotalInfo[hotelPlan].reservationItemsRegistered += amount;
        hotelAdminTotalInfo[hotelAdmin].reservationItemsRegistered += amount;
    }

    function handleFinishReservation(address hotelPlan, address user, address hotelAdmin, uint256 amountSuccess, uint256 amountFailure) external onlyReservation {
        if (amountSuccess > 0) {
            userTotalInfo[user].reservationItemsSuccess += amountSuccess;
            userPerHotelInfo[user][hotelPlan].reservationItemsSuccess += amountSuccess;
            hotelTotalInfo[hotelPlan].reservationItemsSuccess += amountSuccess;
            hotelAdminTotalInfo[hotelAdmin].reservationItemsSuccess += amountSuccess;
        }
        if (amountFailure > 0) {
            userTotalInfo[user].reservationItemsFailure += amountFailure;
            userPerHotelInfo[user][hotelPlan].reservationItemsFailure += amountFailure;
            hotelTotalInfo[hotelPlan].reservationItemsFailure += amountFailure;
            hotelAdminTotalInfo[hotelAdmin].reservationItemsFailure += amountFailure;
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IReservationFactory {

    function externalModule() external view returns(address);

    function signer() external view returns(address);

    function isDeployedByFactory(address) external view returns(bool);

    function deployReservation(address hotelPlan) external returns(address);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IHotelPlanFactory {

    function externalModule() external view returns(address);

    function platformAdmin() external view returns(address);

    function signer() external view returns(address);

    function baseURI() external view returns(string memory);

    function addedFee() external view returns(uint256);
    
    function isDeployedByFactory(address) external view returns(bool);

    function ratio() external view returns(uint256[4] memory);

    function deployHotelPlan(string memory name, string memory symbol, address hotelAdmin) external returns(address);
}