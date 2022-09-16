/**
 *Submitted for verification at BscScan.com on 2022-09-16
*/

// SPDX-License-Identifier: RXFNDTN

pragma solidity ^0.7.4;

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ //
// ░░██████╗░░░███████╗░░██╗░░░██╗░░ //  CONTRACT:
// ░░██╔══██╗░░██╔════╝░░╚██╗░██╔╝░░ //  DEX / DECENTRALIZED EXCHANGE for REX STAKES
// ░░██████╔╝░░█████╗░░░░░╚████╔╝░░░ //  PART OF "REX" SMART CONTRACTS
// ░░██╔══██╗░░██╔══╝░░░░░██╔═██╗░░░ //
// ░░██║░░██║░░███████╗░░██╔╝░░██╗░░ //  FOR DEPLOYMENT ON NETWORK:
// ░░╚═╝░░╚═╝░░╚══════╝░░╚═╝░░░╚═╝░░ //  BINANCE SMART CHAIN - ID: 56
// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ //
// ░░ Latin: king, ruler, monarch ░░ //
// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ //
// ░░░ Copyright (C) 2022 rex.io ░░░ //  SINGLE SOURCE OF TRUTH: rex.io
// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ //

/**
 *
 * GENERAL SHORT DESCRIPTION
 *
 * REX is a staking token, providing the ability to sell/buy stakes on a DEX for STAKES
 * This contract implements a decentralized exchange ("DEX") for the REX STAKES.
 *
 * The contract creates and maintains a list of offered STAKES (that had been created in REX CONTRACT)
 * utilizing a mapping (uint256 number -> Struct StakeOffer) called "stakeOffers [offer_number]",
 * with the Struct containing the STAKES and OFFER details, like, for example:
 * the address "staker", the stake's price, offerDurationDays and the stakeID (and more).
 *
 * OFFERING a stake
 * The offering itself is triggered from REX CONTRACT (see function "offerStake"),
 * calling the "listStake" function in here, that will create a new stakeOffers[number++].
 *
 * BUYING a stake
 * Users may buy an active, not-expired stake OFFER here using external "buyStakeFromList()".
 * The BUSD (price of the stake, as set by the seller) and a FEE are being transferred.
 * There is no fee when the buyer holds MREX.
 * buyStakeFromList() finally triggers the REX CONTRACT:
 *   1) to create the buyer a new active stake (with the properties of the bought stake)
 *   2) and also to set the "sold stake" as closed (not paying any rewards)
 *
 * FEE
 * A fee of 2% (of the stake's BUSD price) is withdrawn from the buyer, if the buyer is not an MREX_TOKEN holder
 *
 * REVOKING an offer
 * For the SELLER, this contract provides the "revokeOffer" function, to end/revoke an offer anytime.
 * This sets the OFFER to "isActive = false" (so buyers can't buy it any longer).
 * "revokeOffer" also calls REX CONTRACT's "restoreStake" to re-activate the stake for the seller
 *
 * When a stake has been offered and hasn't been bought within the "offerDurationDays",
 * the offering address must actively "revokeOffer()" to reactivate their stake within REX CONTRACT.
 *
 * Users take notice of the status of their stakes:
 *   1) Offered stakes will appear as "STAKE offered on DEX"
 *   2) Sold stakes will appear as "SOLD on DEX"
 *   3) Bought stakes will appear as "BOUGHT on DEX"
 *
 * The contract provides the following globals:
 * "totalActiveOffers", "totalFulfilledOffers", "totalRevokedOffers", "totalTradingVolume"
 *
 * "ADMIN RIGHTS"
 * The deploying address "TOKEN_DEFINER" has only one right:
 * Calling initRexContract() providing the address of REX_CONTRACT.
 * This is needed to link the two contracts after deployment.
 * Afterwards, the TOKEN_DEFINER shall call "revokeAccess", so this can only be done once.
 * No further special rights are granted to the TOKEN_DEFINER (or any other address).
 *
 */

interface IREXToken {

    function currentRxDay()
        external view
        returns (uint32);

    function restoreStake(
        address _staker,
        bytes16 _stakeID
    ) external;

    function createBoughtStake(
        bytes16 _stakeID,
        address _fromAddress,
        address _toAddress
    ) external;

    function _checkStakeDataByID(
        address _staker,
        bytes16 _stakeID
    ) external view
        returns (bool, uint8, uint32, uint32, uint256, uint256);

}

interface IBEP20 {
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

contract RexDEX {

    using RexSafeMath for uint256;
    using RexSafeMath32 for uint32;

    address public TOKEN_DEFINER;   // for initializing contracts after deployment
    IREXToken public REX_CONTRACT;
    IBEP20 public BUSD_TOKEN;
    IBEP20 public MREX_TOKEN;

    address private constant busd_address = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address private constant MARKETING_ADDR = 0x231f8084fECEee5b90021C42C083FEB73d4182F9;
    address private constant DEVELOPMENT_ADDR = 0xF3393b11Dc4CADFDc5BCed0F7BEB9d09Ce5C78D6;
    address constant mrex_address = 0x76837D56D1105bb493CDDbEFeDDf136e7c34f0c4;

    uint256 public noOfOffers;

    mapping(uint256 => StakeOffer) public stakeOffers;

    struct StakeOffer {
        bool isActive;
        address staker;
        uint32 offerStartDay;
        uint32 offerDurationDays;
        uint256 offerPrice;
        bytes16 stakeID;
    }

    struct Globals {
        uint256 totalActiveOffers;
        uint256 totalFulfilledOffers;
        uint256 totalRevokedOffers;
        uint256 totalTradingVolume;
    }

    Globals public gl;

    event NewOffer(address indexed seller, uint256 indexed price, bytes16 stakeID);
    event StakeSold(address indexed seller, address indexed buyer, uint256 indexed price, bytes16 stakeID);
    event OfferRevoked(address indexed seller, bytes16 stakeID);

    /**
     * @notice For initializing the contract
     */
    modifier onlyTokenDefiner() {
        require( msg.sender == TOKEN_DEFINER, 'DEX: Not allowed.' );
        _;
    }

    receive() external payable { revert(); }
    fallback() external payable { revert(); }


    // init functions

    function initRexContract(address _REX) external onlyTokenDefiner {
        REX_CONTRACT = IREXToken(_REX);
    }

    function revokeAccess() external onlyTokenDefiner {
        TOKEN_DEFINER = address(0x0);
    }

    constructor() {
        TOKEN_DEFINER = msg.sender;
        BUSD_TOKEN = IBEP20(busd_address);
        MREX_TOKEN = IBEP20(mrex_address);
    }

    function listStake(
        address _staker,
        uint32 _offerStartDay,
        uint32 _offerDurationDays,
        uint256 _offerPrice,
        bytes16 _stakeID
    )
        external
    {
        require(msg.sender == address(REX_CONTRACT), "DEX: Can only be called by REX contract.");

        uint256 _ID = noOfOffers;
        noOfOffers = noOfOffers.add(1);

        StakeOffer memory _offer;

        _offer.isActive = true;
        _offer.staker = _staker;
        _offer.offerStartDay = _offerStartDay;
        _offer.offerDurationDays = _offerDurationDays;
        _offer.offerPrice = _offerPrice;
        _offer.stakeID = _stakeID;

        stakeOffers[_ID] = _offer;

        gl.totalActiveOffers = gl.totalActiveOffers.add(1);

        emit NewOffer(_staker, _offerPrice, _stakeID);
    }


    /**
     * @notice Function for a user (not a contract) to buy a STAKE using BUSD
     * @dev APPROVE (contract, amount) first! -> PRICE + (if !MREX holder:) offerPrice*0.01 (BUSD) for service
     * @param _offerID of the STAKE
     */
    function buyStakeFromList(
        uint256 _offerID
    )
        external
    {
        StakeOffer storage _offer = stakeOffers[_offerID];

        require(_offer.staker != msg.sender, "DEX: Cannot buy your own stake.");
        require(_offer.isActive, "DEX: Offer not active.");
        require(_notContract(msg.sender) && msg.sender == tx.origin, 'DEX: Buyer not an address');

        bool _notExpired = _currentRxDay() <= ( _offer.offerStartDay.add(_offer.offerDurationDays) );
        require(_notExpired, "DEX: Offer has expired.");

        _offer.isActive = false; // reentrancy check

          // If the caller is not an MREX HOLDER: pay a fee of 2% (1% to MARKETING_ADDRESS and 1% DEVELOPMENT_ADDR)
        if( MREX_TOKEN.balanceOf(msg.sender) == 0 )
        {
            uint256 _fee = _offer.offerPrice.div(100); // fee = 1% = 1/100 of offer price
            require(BUSD_TOKEN.transferFrom(msg.sender, MARKETING_ADDR, _fee), "DEX: M-Fee transfer failed."); // pay
            require(BUSD_TOKEN.transferFrom(msg.sender, DEVELOPMENT_ADDR, _fee), "DEX: D-Fee transfer failed."); // pay
        }

          // pay the seller
        require(BUSD_TOKEN.transferFrom(msg.sender, _offer.staker, _offer.offerPrice), "DEX: Transfer of BUSD failed.");

        gl.totalActiveOffers = gl.totalActiveOffers >= 1 ? gl.totalActiveOffers.sub(1) : 0;
        gl.totalFulfilledOffers = gl.totalFulfilledOffers.add(1);
        gl.totalTradingVolume = gl.totalTradingVolume.add(_offer.offerPrice);

        REX_CONTRACT.createBoughtStake(_offer.stakeID, _offer.staker, msg.sender);

        emit StakeSold(_offer.staker, msg.sender, _offer.offerPrice, _offer.stakeID);
    }

    function revokeOffer(
        uint256 _offerID
    )
        external
    {
        StakeOffer storage _offer = stakeOffers[_offerID];

        require(_offer.staker == msg.sender, "DEX: Only stake owner");
        require(_offer.isActive, "DEX: Cannot revoke");

        _offer.isActive = false;

        gl.totalActiveOffers = gl.totalActiveOffers.sub(1);
        gl.totalRevokedOffers = gl.totalRevokedOffers.add(1);

        REX_CONTRACT.restoreStake(msg.sender, _offer.stakeID);

        emit OfferRevoked(msg.sender, _offer.stakeID);
    }

    /** @notice Shows current day of RexToken
      * @dev Fetched from REX_CONTRACT
      * @return Iteration day since REX inception
      */
    function _currentRxDay() public view returns (uint32) {
        return REX_CONTRACT.currentRxDay();
    }

    function _notContract(address _addr) internal view returns (bool) {
        uint32 size; assembly { size := extcodesize(_addr) } return (size == 0); }

    function dataOfOfferNumber(uint256 _offerID) external view
        returns (address staker, bool[2] memory _bools, uint8 isIrrTrex, uint32[4] memory _days, uint256[3] memory _amounts)
    {

        staker = stakeOffers[_offerID].staker;

        _bools[0] = stakeOffers[_offerID].isActive;
        _days[0] = stakeOffers[_offerID].offerStartDay;
        _days[1] = stakeOffers[_offerID].offerDurationDays;
        _amounts[0] = stakeOffers[_offerID].offerPrice;

          // load the rest of the STAKE data:
          // _stake.isSplit, _stake.isIrrTrex, _stake.startDay, _stake.finalDay, _stake.stakesShares, _stake.stakedAmount
        (
        _bools[1],
        isIrrTrex,
        _days[2],
        _days[3],
        _amounts[1],
        _amounts[2] ) = REX_CONTRACT._checkStakeDataByID(staker, stakeOffers[_offerID].stakeID);

    }
}

library RexSafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, 'DEX: addition overflow');
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, 'DEX: subtraction overflow');
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, 'DEX: multiplication overflow');

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, 'DEX: division by zero');
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, 'DEX: modulo by zero');
        return a % b;
    }
}

library RexSafeMath32 {

    function add(uint32 a, uint32 b) internal pure returns (uint32) {
        uint32 c = a + b;
        require(c >= a, 'DEX: addition overflow');
        return c;
    }

    function sub(uint32 a, uint32 b) internal pure returns (uint32) {
        require(b <= a, 'DEX: subtraction overflow');
        uint32 c = a - b;
        return c;
    }

    function mul(uint32 a, uint32 b) internal pure returns (uint32) {

        if (a == 0) {
            return 0;
        }

        uint32 c = a * b;
        require(c / a == b, 'DEX: multiplication overflow');

        return c;
    }

    function div(uint32 a, uint32 b) internal pure returns (uint32) {
        require(b > 0, 'DEX: division by zero');
        uint32 c = a / b;
        return c;
    }

    function mod(uint32 a, uint32 b) internal pure returns (uint32) {
        require(b != 0, 'DEX: modulo by zero');
        return a % b;
    }
}